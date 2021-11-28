#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
import subprocess

print('Hello, remote world!')
# The nvidia-smi command will generally report the driver version installed on the base machine,
rc = subprocess.call("nvidia-smi")
# whereas other version methods like nvcc will report the CUDA version installed inside the docker container
rc = subprocess.call("nvcc --version")