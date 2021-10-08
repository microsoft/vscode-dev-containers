# Display a notice when not running in GitHub Codespaces

cat << 'EOF' > /usr/local/etc/vscode-dev-containers/conda-notice.txt
👋 Welcome to your new Anaconda development container!

Note that your use of third-party packages may be subject to additional licensing requirements.
When using "conda", note that the Anaconda repository contains restrictions on commercial use 
that may impact certain organizations. See https://www.anaconda.com/terms-of-service

EOF

notice_script="$(cat << 'EOF'
if [ -t 1 ] && [ "${IGNORE_NOTICE}" != "true" ] && [ "${TERM_PROGRAM}" = "vscode" ] && [ "${CODESPACES}" != "true" ] && [ ! -f "$HOME/.config/vscode-dev-containers/conda-notice-already-displayed" ]; then
    cat "/usr/local/etc/vscode-dev-containers/conda-notice.txt"
    mkdir -p "$HOME/.config/vscode-dev-containers"
    ((sleep 10s; touch "$HOME/.config/vscode-dev-containers/conda-notice-already-displayed") &)
fi
EOF
)"

echo "${notice_script}" | tee -a /etc/bash.bashrc >> /etc/zsh/zshrc
