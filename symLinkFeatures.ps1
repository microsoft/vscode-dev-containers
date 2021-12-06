# To run this you will need to ensure a few things first:
# 1. temporarily change the execution policy: Set-ExecutionPolicy Unrestricted -Scope Process
# 2. download and extract the latest dev-containers release from https://github.com/microsoft/vscode-dev-containers/releases/
# 3. Rename the root folder of that extracted release from "package" to "vscode-dev-containers" 


# Run the script in powershell with the following three arguments:
# ./symLinkFeatures.ps1 "full/path/to/vscode-dev-containers-repo" "full/path/to/vscode-dev-containers-repo/extensions" "full/path/to/vscode-dev-containers" "full/path/to/vscode-remote-containers"

$devContainersRepoPath=$args[0]
$devContainersReleasePath=$args[1]
$remoteContainersRepoPath=$args[2]

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