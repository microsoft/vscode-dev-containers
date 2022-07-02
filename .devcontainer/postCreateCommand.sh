#!/usr/bin/env bash
install_extension() {
    /usr/bin/code --install-extension $1
    /usr/bin/code-insiders --install-extension $1
}

# Install VS Code extensions into VS Code in desktop so we can try
install_extension ms-vscode-remote.remote-containers
install_extension ms-azuretools.vscode-docker
install_extension streetsidesoftware.code-spell-checker
install_extension chrisdias.vscode-opennewinstance
install_extension mads-hartmann.bash-ide-vscode
install_extension rogalmic.bash-debug
