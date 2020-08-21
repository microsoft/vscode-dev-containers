#!/bin/bash

USERNAME=${1:-codespace}
DOTNET_ROOT=${2:-"/home/${USERNAME}/.dotnet"}

# Define extra paths:Language executables provided by Oryx -  see https://github.com/microsoft/Oryx/blob/master/images/build/slim.Dockerfile#L223
# Also adds ~/.npm-global/bin - For npm global and carg bin directory in user directory
EXTRA_PATHS="/opt/oryx:/opt/nodejs/lts/bin:/opt/python/latest/bin:/opt/yarn/stable/bin:${DOTNET_ROOT}/tools"
USER_EXTRA_PATHS_OVERRIDES="\$HOME/.dotnet"
USER_EXTRA_PATHS="${EXTRA_PATHS}:\$HOME/.npm-global/bin"

BASH_PROMPT="PS1='\[\e]0;\u: \w\a\]\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"
FISH_PROMPT="function fish_prompt\n    set_color green\n    echo -n (whoami)\n    set_color normal\n    echo -n \":\"\n    set_color blue\n    echo -n (pwd)\n    set_color normal\n    echo -n \"> \"\nend\n"

{ echo && echo $BASH_PROMPT ; } | tee -a /etc/skel/.bashrc /root/.bashrc /home/${USERNAME}/.bashrc >> /etc/bash.bashrc
{ echo && echo -e "export PATH=${USER_EXTRA_PATHS_OVERRIDES}:${USER_EXTRA_PATHS}:\$PATH" ; } | tee -a /etc/skel/.bashrc /etc/skel/.zshrc /root/.bashrc /root/.zshrc /home/${USERNAME}/.bashrc /home/${USERNAME}/.zshrc >> /etc/bash.bashrc
echo "Defaults secure_path=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin:${EXTRA_PATHS}\"" >> /etc/sudoers.d/securepath

# Install and setup fish
apt-get install -yq fish
printf "$FISH_PROMPT" >> /etc/fish/conf.d/fish_prompt.fish

# Add user to a Docker group
sudo -u ${USERNAME} mkdir /home/${USERNAME}/.vsonline
groupadd -g 800 docker
usermod -a -G docker ${USERNAME}

# Set VS Code as user's git edtior
tee /tmp/scripts/git-ed.sh > /dev/null << EOF
#!/usr/bin/env bash

if [[ \$(which code-insiders) && ! \$(which code) ]]; then
  GIT_ED="code-insiders"
else
  GIT_ED="code"
fi

$GIT_ED --wait \$@
EOF

sudo -u ${USERNAME} mkdir -p /home/${USERNAME}/.local/bin
install -o ${USERNAME} -g ${USERNAME} -m 755 /tmp/scripts/git-ed.sh /home/${USERNAME}/.local/bin/git-ed.sh
sudo -u ${USERNAME} git config --global core.editor "/home/${USERNAME}/.local/bin/git-ed.sh"
rm -f /tmp/scripts/git-ed.sh
