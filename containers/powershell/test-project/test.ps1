#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------


param([int]$Count=50, [int]$DelayMilliseconds=200)

function Write-Item($itemCount) {
    $i = 1

    while ($i -le $itemCount) {
        $str = "Output $i"
        Write-Output $str

        # In the gutter on the left, right click and select "Add Conditional Breakpoint"
        # on the next line. Use the condition: $i -eq 25
        $i = $i + 1

        # Slow down execution a bit so user can test the "Pause debugger" feature.
        Start-Sleep -Milliseconds $DelayMilliseconds
    }
}


function Do-Work($workCount) {
    Write-Output "Doing remote work..."
    Write-Item $workcount
    Write-Host "Done!"
}

Do-Work $Count
