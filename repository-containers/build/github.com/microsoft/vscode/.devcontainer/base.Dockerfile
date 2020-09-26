#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# **********************************************************************************************************
# ** This file generates the "mcr.microsoft.com/vscode/devcontainers/repos/microsoft/vscode" image that's **
# ** referenced in devcontainer.json. To iterate on it, change devcontainer.json to use this Dockerfile.  **
# **********************************************************************************************************

FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:0-12

ARG INSTALL_FIREFOX="true"
COPY library-scripts/desktop-lite-debian.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
	&& bash /tmp/library-scripts/desktop-lite-debian.sh \
	&& sed -i -E 's/.*Terminal.*/    [exec] (Terminal) { tilix -w ~ -e $(readlink -f \/proc\/$$\/exe) -il } <>\n    [exec] (Start Code - OSS) { tilix -t "Code - OSS Build" -e bash \/home\/node\/workspace\/vscode*\/scripts\/code.sh  } <>/' /home/node/.fluxbox/menu \
	&& if [ "${INSTALL_FIREFOX}" = "true" ]; then apt-get -y install firefox-esr; fi \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/*

# VNC options
ARG MAX_VNC_RESOLUTION=1920x1080x16
ARG TARGET_VNC_RESOLUTION=1440x900
ARG TARGET_VNC_DPI=96
ARG TARGET_VNC_PORT=5901

# Core environment variables for X11, VNC, and fluxbox
ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" \
	MAX_VNC_RESOLUTION="${MAX_VNC_RESOLUTION}" \
	VNC_RESOLUTION="${TARGET_VNC_RESOLUTION}" \
	VNC_DPI="${TARGET_VNC_DPI}" \
	VNC_PORT="${TARGET_VNC_PORT}" \
	NOVNC_PORT="${TARGET_NOVNC_PORT}" \
	DISPLAY=":1" \
	LANG="en_US.UTF-8" \
	LANGUAGE="en_US.UTF-8"

ENTRYPOINT ["/usr/local/share/desktop-init.sh"]
CMD ["sleep", "infinity"]
