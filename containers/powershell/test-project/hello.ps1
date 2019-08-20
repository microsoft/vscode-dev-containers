#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

param([int]$Count=50, [int]$DelayMilliseconds=50)

function Write-Item($itemCount) {
    $i = 1
    while ($i -le $itemCount) {
        $str = "Hello remote world #$i!"
        Write-Output $str
        $i = $i + 1
        Start-Sleep -Milliseconds $DelayMilliseconds
    }
}

function Hello($workCount) {
    Write-Output "Saying hello..."
    Write-Item $workcount
    Write-Host "Done saying hello!"
}

Hello $Count
