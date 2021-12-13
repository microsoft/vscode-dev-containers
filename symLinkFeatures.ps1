# To run this you will need to ensure a few things first:
# 1. temporarily change the execution policy: Set-ExecutionPolicy Unrestricted -Scope Process
# 2. download and extract the latest dev-containers release from https://github.com/microsoft/vscode-dev-containers/releases/
# 3. Rename the root folder of that extracted release from its default name to "vscode-dev-containers" 
# 3a. It is recommended that you put the package in a different directory than the vscode-dev-containers repo to prevent naming conflicts.
#     The package directory MUST be named "vscode-dev-containers" due to limitations of `yarn link`, so either rename the repo directory or
#     put the package in a different directory. 

# Run the script in powershell with the following three arguments:
# ./symLinkFeatures.ps1 "full/path/to/repo/vscode-dev-containers" "full/path/to/release-package/vscode-dev-containers" "full/path/to/repo/vscode-remote-containers"
# Example:
# cd C:\Users\myusername\src
# .\vscode-dev-containers\symLinkFeatures.ps1 "$pwd\vscode-dev-containers" "$pwd\packages\vscode-dev-containers" "$pwd\vscode-remote-containers"

# The script will need to be rerun if you add or remove files from "\script-library\container-features\src" or "\script-library"

$devContainersRepoPath=$args[0]
$devContainersReleasePath=$args[1]
$remoteContainersRepoPath=$args[2]

cd $devContainersReleasePath
yarn unlink
cd $remoteContainersRepoPath
yarn unlink vscode-dev-containers

foreach($file in Get-ChildItem "$devContainersRepoPath\script-library\container-features\src")
{
write-host LINKING $file.FullName
New-Item -ItemType SymbolicLink -Path "$devContainersReleasePath\container-features\$file" -Target $file.FullName -Force
}

foreach($file in Get-ChildItem "$devContainersRepoPath\script-library" *.sh)
{
write-host $file.FullName
New-Item -ItemType SymbolicLink -Path "$devContainersReleasePath\container-features\$file" -Target $file.FullName -Force
}

cd $devContainersReleasePath
yarn link
cd $remoteContainersRepoPath
yarn link vscode-dev-containers