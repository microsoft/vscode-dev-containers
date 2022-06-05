FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:16-bullseye

ARG NODE_VERSION="16"
COPY library-scripts/desktop-lite-debian.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
	&& bash /tmp/library-scripts/desktop-lite-debian.sh \
	&& sed -i -E 's/.*Terminal.*/    [exec] (Terminal) { tilix -w ~ -e $(readlink -f \/proc\/$$\/exe) -il } <>\n    [exec] (Start Code - OSS) { tilix -t "Code - OSS Build" -e bash \/home\/node\/workspace\/vscode*\/scripts\/code.sh  } <>/' /home/node/.fluxbox/menu \
	&& apt-get -y install firefox-esr \
	&& bash -c ". /usr/local/share/nvm/nvm.sh && nvm alias ${VARIANT} system" \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

# Core environment variables for X11, VNC, and fluxbox
ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" \
	VNC_RESOLUTION="1440x768x16" \
	VNC_DPI="96" \
	VNC_PORT="5901" \
	NOVNC_PORT="6080" \
	DISPLAY=":1" \
	LANG="en_US.UTF-8" \
	LANGUAGE="en_US.UTF-8"

ENTRYPOINT ["/usr/local/share/desktop-init.sh"]
CMD ["sleep", "infinity"]
