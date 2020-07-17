# -------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
# -------------------------------------------------------------------------------------------------------------

"""This example lights up all the NeoPixel LEDs red and the green in an infinit loop."""
from adafruit_circuitplayground import cp
import time

while True:
    cp.pixels.fill((50, 0, 0))
    time.sleep(0.5)
    cp.pixels.fill((50, 205, 50))
    time.sleep(0.5)
