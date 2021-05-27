#!/usr/bin/env bash
DEFAULT_SHELL_TYPE=$1

set -e

apt-get update
apt-get -y install zsh

echo -e "export PATH=/front-profile-begin:\$PATH:/back-profile-begin\n$(cat /etc/profile)" > /etc/profile
echo -e "export PATH=/front-profile-begin:\$PATH:/back-profile-begin\n$(cat /etc/zsh/zlogin)" > /etc/zsh/zlogin
sed -i 's%export PATH$%&\nexport PATH=/front-profile-post-export:$PATH:/back-profile-post-export%g' /etc/profile
sed -i 's%if \[ "\${PS1-}" \]; then%export PATH=/front-profile-pre-rc:$PATH:/back-profile-pre-rc\n&%g' /etc/profile
sed -i 's%if \[ -d /etc/profile\.d \]; then%export PATH=/front-pre-profile.d:$PATH:/back-pre-profile.d\n&%g' /etc/profile
echo "export PATH=/front-profile-end:\$PATH:/back-profile-end" | tee -a /etc/zsh/zlogin >> /etc/profile
echo "export PATH=/front-rc:\$PATH:/back-rc" | tee -a /etc/zsh/zshrc >> /etc/bash.bashrc
echo "etc_env_var=true" >> /etc/environment

echo -e "vscode\nvscode" | passwd root 2>&1
USERNAME="$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd 2>/dev/null)"
if [ "${USERNAME}" != "" ]; then
    chown $USERNAME /usr/local/share/ssh-init.sh
    echo -e "vscode\nvscode" | passwd $USERNAME 2>&1
    chsh -s $(which $DEFAULT_SHELL_TYPE) $USERNAME
fi
