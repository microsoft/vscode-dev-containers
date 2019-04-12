#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM jupyter/pyspark-notebook

USER root

# Install git, process tools
RUN apt-get update && apt-get -y install git procps

# Install any missing dependencies for enhanced language service
RUN apt-get install -y libicu[0-9][0-9]

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy jupyter_notebook_config.py with token that matches settings
COPY jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py

# Copy default endpoint specific user settings overrides into container to specify Python path, token
COPY settings.vscode.json /home/jovyan/.vscode-remote/data/Machine/settings.json

RUN chown jovyan -R /home/jovyan

USER jovyan

RUN pip install pylint



