#!/bin/bash
#--------------------------------------------------------------------------------------------------------------
#  Copyright (c) Microsoft Corporation. All rights reserved.
#  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#--------------------------------------------------------------------------------------------------------------

set -ex

splitSdksDir="/opt/dotnet"

allSdksDir="/home/codespace/.dotnet"
mkdir -p "$allSdksDir"

# Copy latest muxer and license files
cp -f "$splitSdksDir/lts/dotnet" "$allSdksDir"
cp -f "$splitSdksDir/lts/LICENSE.txt" "$allSdksDir"
cp -f "$splitSdksDir/lts/ThirdPartyNotices.txt" "$allSdksDir"

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

# Dynamically find and link all installed dotnet SDKs
find /opt/dotnet/*.*.*/sdk -maxdepth 1 -type d -name "*.*.*" | while read SDK_PATH; do
    SDK_VERSION="$(basename ${SDK_PATH})"
    createLinks "$SDK_VERSION"
done

set +ex