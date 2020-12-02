#!/bin/bash
#--------------------------------------------------------------------------------------------------------------
#  Copyright (c) Microsoft Corporation. All rights reserved.
#  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#--------------------------------------------------------------------------------------------------------------

set -ex

splitSdksDir="/opt/dotnet/sdks"

allSdksDir="/home/codespace/.dotnet"
mkdir -p "$allSdksDir"

# Copy latest muxer and license files
cp -f "$splitSdksDir/3/dotnet" "$allSdksDir"
cp -f "$splitSdksDir/3/LICENSE.txt" "$allSdksDir"
cp -f "$splitSdksDir/3/ThirdPartyNotices.txt" "$allSdksDir"

function createLinks() {
    local sdkVersion="$1"
    
    installedDir="$splitSdksDir/$sdkVersion"
    cd "$installedDir"

    # Find folders with the name being a version number like 3.1.0 or 3.1.301
    find . -maxdepth 3 -type d -regex '.*/[0-9]\.[0-9]\.[0-9]+' | while read subPath; do
        # Trim beginning 2 characters from the line which currently looks like, for example, './sdk/2.2.402'
        subPath="${subPath:2}"
        
        linkFrom="$allSdksDir/$subPath"
        linkFromParentDir=$(dirname $linkFrom)
        mkdir -p "$linkFromParentDir"

        linkTo="$installedDir/$subPath"
        ln -sTf $linkTo $linkFrom
    done
}

createLinks "3.1.301"
echo
createLinks "3.0.103"
echo
createLinks "2.2.402"
echo
createLinks "2.1.807"
echo
createLinks "1.1.14"