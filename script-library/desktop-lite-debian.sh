#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Syntax: ./desktop-lite-debian.sh [non-root user] [vnc password] [install no vnc flag]
#
# Usage:
#
# 1. Add this file to .devcontainer/library-scripts
#
# 2. Add the following to your .devcontainer/Dockerfile:
#
#    COPY library-scripts/desktop-lite-debian.sh /tmp/library-scripts/
#    RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#        && bash /tmp/library-scripts/dekstop-lite-debian.sh
#    ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" DISPLAY=":1" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
#    ENTRYPOINT ["/usr/local/share/desktop-init.sh"]
#    CMD ["sleep", "infinity"]
#
#  The ENTRYPOINT script can be chained with another script by adding it to the array after desktop-init.sh.
#
# 3. And the following to devcontainer.json:
#
#    "runArgs": ["--init", "--security-opt", "seccomp=unconfined"],
#    "forwardPorts": [6080, 5901],
#    "overrideCommand": false
# 
# 4. You'll be able to use a web based desktop viewer on port **6080** or connect a VNC viewer to port **5901**.
#
# 5. Default **password**: vscode 
#
# The window manager is Fluxbox (http://fluxbox.org/). **Right-click** to see the application menu. If you need
# a browser, you can install Firefox ESR by adding the following to your Dockerfile:
#
#    RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y firefox-esr
# 
# Or if you want the full version of Google Chrome, add the following to your Dockerfile instead:
#
#    RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#        && curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb \
#        && apt-get -y install /tmp/chrome.deb \
#        && rm -rf /tmp/chrome.deb
#
# Finally, if you need to select a different locale, be sure to add it to /etc/locale.gen and run locale-gen. 

USERNAME=${1:-"vscode"}
VNC_PASSWORD=${2:-"vscode"}
INSTALL_NOVNC=${3:-"true"}

PACKAGE_LIST="
    xvfb \
    x11vnc \
    fluxbox \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    xdg-utils \
    fbautostart \
    xterm \
    eterm \
    tilix \
    nautilus\
    mousepad \
    seahorse \
    gnome-icon-theme \
    gnome-keyring \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    libnotify4 \
    libnss3 \
    libxss1 \
    libgdm1 \
    libasound2 \
    xfonts-base \
    xfonts-terminus \
    fonts-noto \
    fonts-wqy-microhei \
    fonts-droid-fallback \
    python3-numpy \
    htop \
    ncdu \
    curl \
    ca-certificates\
    unzip \
    nano \
    locales"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run a root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Treat a user name of "none" or non-existant user as root
if [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

# Function to run apt-get if needed
apt-get-update-if-needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

apt-get-update-if-needed

# On older Ubuntu, Tilix is in a PPA. On Debian Strech, its in backports
if [[ -z $(apt-cache --names-only search ^tilix$) ]]; then
    apt-get install -y --no-install-recommends lsb-release
    if [ "$(lsb_release -is)" = "Ubuntu" ]; then
        apt-get install -y --no-install-recommends apt-transport-https software-properties-common
        add-apt-repository -y ppa:webupd8team/terminix
    else
        echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" > /etc/apt/sources.list.d/$(lsb_release -cs)-backports.list
    fi
    apt-get update
fi

# Install X11, fluxbox and VS Code dependencies
if ! dpkg -s ${PACKAGE_LIST} > /dev/null 2>&1; then
    apt-get -y install --no-install-recommends ${PACKAGE_LIST}
fi

# Check at least one locale exists
if ! grep -o -E '^\s*en_US.UTF-8\s+UTF-8' /etc/locale.gen > /dev/null; then
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen 
    locale-gen
fi

# Install the Cascadia Code fonts - https://github.com/microsoft/cascadia-code
if [ ! -d "/usr/share/fonts/truetype/cascadia" ]; then
    curl -sSL https://github.com/microsoft/cascadia-code/releases/download/v2008.25/CascadiaCode-2008.25.zip -o /tmp/cascadia-fonts.zip
    unzip /tmp/cascadia-fonts.zip -d /tmp/cascadia-fonts
    mkdir -p /usr/share/fonts/truetype/cascadia
    mv /tmp/cascadia-fonts/ttf/* /usr/share/fonts/truetype/cascadia/
    rm -rf /tmp/cascadia-fonts.zip /tmp/cascadia-fonts
fi

# Install noVNC
NOVNC_VERSION=1.2.0
WEBSOCKETIFY_VERSION=0.9.0
if [ "${INSTALL_NOVNC}" = "true" ] && [ ! -d "/usr/local/novnc" ]; then
    mkdir -p /usr/local/novnc
    curl -sSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.zip -o /tmp/novnc-install.zip
    unzip /tmp/novnc-install.zip -d /usr/local/novnc
    cp /usr/local/novnc/noVNC-${NOVNC_VERSION}/vnc_lite.html /usr/local/novnc/noVNC-${NOVNC_VERSION}/index.html
    curl -sSL https://github.com/novnc/websockify/archive/v${WEBSOCKETIFY_VERSION}.zip -o /tmp/websockify-install.zip
    unzip /tmp/websockify-install.zip -d /usr/local/novnc
    ln -s /usr/local/novnc/websockify-${WEBSOCKETIFY_VERSION} /usr/local/novnc/noVNC-${NOVNC_VERSION}/utils/websockify
    # Tweak websocketify to use python3 since python 2 may not be installed
    sed -i -E "s/^python\s/\/usr\/bin\/python3 /g" /usr/local/novnc/websockify-${WEBSOCKETIFY_VERSION}/run
    rm -f /tmp/websockify-install.zip /tmp/novnc-install.zip
fi 

# Set up folders for scripts and init files
mkdir -p /var/run/dbus /usr/local/etc/vscode-dev-containers/ /root/.fluxbox

# Script to change resolution of desktop
tee /usr/local/bin/set-resolution > /dev/null \
<< EOF 
#!/bin/bash
RESOLUTION=\${1:-\${VNC_RESOLUTION:-1920x1080}}
DPI=\${2:-\${VNC_DPI:-96}}
if [ -z "\$1" ]; then
    echo -e "**Current Settings **\n"
    xrandr
    echo -n -e "\nEnter new resolution (WIDTHxHEIGHT, blank for \${RESOLUTION}, Ctrl+C to abort).\n> "
    read NEW_RES
    if [ "\${NEW_RES}" != "" ]; then
        RESOLUTION=\${NEW_RES}
    fi
    if ! echo "\${RESOLUTION}" | grep -E '[0-9]+x[0-9]+' > /dev/null; then
        echo -e "\nInvalid resolution format!\n"
        exit 1
    fi
    if [ -z "\$2" ]; then
        echo -n -e "\nEnter new DPI (blank for \${DPI}, Ctrl+C to abort).\n> "
        read NEW_DPI
        if [ "\${NEW_DPI}" != "" ]; then
            DPI=\${NEW_DPI}
        fi
    fi
fi

xrandr --fb \${RESOLUTION} --dpi \${DPI} > /dev/null 2>&1

if [ \$? -ne 0 ]; then 
    echo -e "\nFAILED TO SET RESOLUTION!\n"
    exit 1
fi

echo -e "\nSuccess!\n"
EOF

# Container ENTRYPOINT script
tee /usr/local/share/desktop-init.sh > /dev/null \
<< EOF 
 #!/bin/bash

USERNAME=${USERNAME}
LOG=/tmp/container-init.log

# Execute the command it not already running
startInBackgroundIfNotRunning()
{
    log "Starting \$1."
    echo -e "\n** \$(date) **" | sudoIf tee -a /tmp/\$1.log > /dev/null
    if ! pidof \$1 > /dev/null; then
        keepRunningInBackground "\$@"
        while ! pidof \$1 > /dev/null; do
            sleep 1
        done
        log "\$1 started."
    else
        echo "\$1 is already running." | sudoIf tee -a /tmp/\$1.log > /dev/null
        log "\$1 is already running."
    fi
}

# Keep command running in background
keepRunningInBackground()
{
    (\$2 sh -l -c "while :; do echo [\\\$(date)] Process started.; \$3; echo [\\\$(date)] Process exited!; sleep 5; done 2>&1" | sudoIf tee -a /tmp/\$1.log > /dev/null & echo "\$!" | sudoIf tee /tmp/\$1.pid > /dev/null)
}

# Use sudo to run as root when required
sudoIf()
{
    if [ "\$(id -u)" -ne 0 ]; then
        sudo "\$@"
    else
        "\$@"
    fi
}

# Use sudo to run as non-root user if not already running
sudoUserIf()
{
    if [ "\$(id -u)" -eq 0 ] && [ "\${USERNAME}" != "root" ]; then
        sudo -u \${USERNAME} "\$@"
    else
        "\$@"
    fi
}

# Log messages
log()
{
    echo -e "[\$(date)] \$@" | sudoIf tee -a \$LOG > /dev/null
}

log "** SCRIPT START **"

# Start dbus.
log 'Running "/etc/init.d/dbus start".'
if [ -f "/var/run/dbus/pid" ] && ! pidof dbus-daemon  > /dev/null; then
    sudoIf rm -f /var/run/dbus/pid
fi
sudoIf /etc/init.d/dbus start 2>&1 | sudoIf tee -a /tmp/dbus-daemon-system.log > /dev/null
while ! pidof dbus-daemon > /dev/null; do
    sleep 1
done

# Set up Xvfb.
startInBackgroundIfNotRunning "Xvfb" sudoIf "Xvfb \${DISPLAY:-:1} +extension RANDR -screen 0 \${MAX_VNC_RESOLUTION:-1920x1080x16}"

# Start fluxbox as a light weight window manager.
startInBackgroundIfNotRunning "fluxbox" sudoUserIf "dbus-launch startfluxbox"

# Start x11vnc
startInBackgroundIfNotRunning "x11vnc" sudoIf "x11vnc -display \${DISPLAY:-:1} -rfbport \${VNC_PORT:-5901} -localhost -no6 -xkb -shared -forever -passwdfile /usr/local/etc/vscode-dev-containers/vnc-passwd"

# Set resolution
/usr/local/bin/set-resolution \${VNC_RESOLUTION:-1440x768} \${VNC_DPI:-96}

# Spin up noVNC if installed and not runnning.
if [ -d "/usr/local/novnc" ] && [ "\$(ps -ef | grep /usr/local/novnc/noVNC*/utils/launch.sh | grep -v grep)" = "" ]; then
    keepRunningInBackground "noVNC" sudoIf "/usr/local/novnc/noVNC*/utils/launch.sh --listen \${NOVNC_PORT:-6080} --vnc localhost:\${VNC_PORT:-5901}"
    log "noVNC started."
else
    log "noVNC is already running or not installed."
fi

# Run whatever was passed in
log "Executing \"\$@\"."
exec "\$@"
log "** SCRIPT EXIT **"
EOF

echo "${VNC_PASSWORD}" > /usr/local/etc/vscode-dev-containers/vnc-passwd
touch /root/.Xmodmap 
chmod +x /usr/local/share/desktop-init.sh /usr/local/bin/set-resolution

tee /root/.fluxbox/apps > /dev/null \
<<EOF
[transient] (role=GtkFileChooserDialog)
  [Dimensions]	{70% 70%}
  [Position]	(CENTER)	{0 0}
[end]
EOF

tee /root/.fluxbox/init > /dev/null \
<<EOF
session.configVersion:	13
session.menuFile:	~/.fluxbox/menu
session.keyFile: ~/.fluxbox/keys
session.styleFile: /usr/share/fluxbox/styles/qnx-photon
session.screen0.workspaces: 1
session.screen0.workspacewarping: false
session.screen0.toolbar.widthPercent: 100
session.screen0.strftimeFormat: %a %l:%M %p
session.screen0.toolbar.tools: prevworkspace, workspacename, nextworkspace, clock, iconbar, systemtray
session.screen0.workspaceNames: One,
EOF

tee /root/.fluxbox/menu > /dev/null \
<<EOF
[begin] (  Application Menu  )
    [exec] (File Manager) { nautilus ~ } <>
    [exec] (Text Editor) { mousepad } <>
    [exec] (Terminal) { tilix -w ~ -e $(readlink -f /proc/$$/exe) -il } <>
    [exec] (Web Browser) { x-www-browser } <>
    [submenu] (System) {}
        [exec] (Set Resolution) { tilix -t "Set Resolution" -e bash /usr/local/bin/set-resolution } <>
        [exec] (Top Processes) { tilix -t "Top" -e htop } <>
        [exec] (Disk Utilization) { tilix -t "Disk Utilization" -e ncdu / } <>
        [exec] (Passwords and Keys) { seahorse } <>
        [exec] (Editres) {editres} <>
        [exec] (Xfontsel) {xfontsel} <>
        [exec] (Xkill) {xkill} <>
        [exec] (Xrefresh) {xrefresh} <>
    [end]
    [config] (Configuration)
    [workspaces] (Workspaces)
[end]
EOF

# Set up non-root user (if one exists)
if [ "${USERNAME}" != "root" ]; then 
    touch /home/${USERNAME}/.Xmodmap
    cp -R /root/.fluxbox /home/${USERNAME}
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.Xmodmap /home/${USERNAME}/.fluxbox
    chown ${USERNAME}:root /usr/local/share/desktop-init.sh /usr/local/bin/set-resolution /usr/local/etc/vscode-dev-containers/vnc-passwd
fi

echo "Done!"
