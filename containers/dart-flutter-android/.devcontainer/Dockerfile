FROM debian:stretch-slim

# Hack to get openjdk to install in a container
RUN mkdir -p /usr/share/man/man1 \
    && mkdir -p /usr/share/man/man7

# Apt
RUN apt update && apt install -y curl wget git xz-utils lib32stdc++6 unzip openjdk-8-jdk-headless

# Android SDK
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip 
RUN mkdir android-sdk && unzip /sdk-tools-linux-4333796.zip -d android-sdk
RUN rm /sdk-tools-linux-4333796.zip
ENV ANDROID_HOME="/android-sdk"
ENV PATH="/android-sdk/tools/bin:/android-sdk/build-tools:/android-sdk/platform-tools:${PATH}"

# SDK manager
RUN yes | sdkmanager --licenses
RUN sdkmanager "platforms;android-28" "platform-tools" "build-tools;28.0.3"

# Flutter
RUN wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.5.4-hotfix.2-stable.tar.xz
RUN tar xf flutter_linux_v1.5.4-hotfix.2-stable.tar.xz 
RUN rm flutter_linux_v1.5.4-hotfix.2-stable.tar.xz
ENV PATH="/flutter/bin:${PATH}"

RUN flutter config --no-analytics

# Set a useful default shell
ENV SHELL /bin/bash

