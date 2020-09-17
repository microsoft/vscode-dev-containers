#!/bin/bash

USERNAME=${1:-codespace}
SECURE_PATH_BASE=${2:-$PATH}

BASH_PROMPT="PS1='\[\e]0;\u: \w\a\]\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"
FISH_PROMPT="function fish_prompt\n    set_color green\n    echo -n (whoami)\n    set_color normal\n    echo -n \":\"\n    set_color blue\n    echo -n (pwd)\n    set_color normal\n    echo -n \"> \"\nend\n"

{ echo && echo $BASH_PROMPT ; } | tee -a /root/.bashrc /home/${USERNAME}/.bashrc  >> /etc/skel/.bashrc
{ echo && echo -e "export PATH=\$HOME/.dotnet:${SECURE_PATH_BASE}:\$PATH:\$HOME/.npm-global/bin" ; } | tee -a /etc/bash.bashrc >> /etc/zsh/zshrc
echo "Defaults secure_path=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin:${SECURE_PATH_BASE}\"" >> /etc/sudoers.d/securepath

# Install and setup fish
apt-get install -yq fish
printf "$FISH_PROMPT" >> /etc/fish/conf.d/fish_prompt.fish
printf "if type code-insiders > /dev/null 2>&1 and ! type code > /dev/null 2>&1\n  alias code=code-insiders\nend" >> /etc/fish/conf.d/code_alias.fish

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

\$GIT_ED --wait \$@
EOF

sudo -u ${USERNAME} mkdir -p /home/${USERNAME}/.local/bin
install -o ${USERNAME} -g ${USERNAME} -m 755 /tmp/scripts/git-ed.sh /home/${USERNAME}/.local/bin/git-ed.sh
sudo -u ${USERNAME} git config --global core.editor "/home/${USERNAME}/.local/bin/git-ed.sh"
rm -f /tmp/scripts/git-ed.sh
