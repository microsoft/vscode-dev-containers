FROM debian:stretch-slim

# Hack to get openjdk to install in a container
RUN mkdir -p /usr/share/man/man1 \
    && mkdir -p /usr/share/man/man7

# Apt
RUN apt-get update && apt-get install -y curl wget git xz-utils lib32stdc++6 unzip openjdk-8-jdk-headless

# Android SDK
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
 &&  mkdir android-sdk && unzip /sdk-tools-linux-4333796.zip -d android-sdk \
 && rm /sdk-tools-linux-4333796.zip
ENV ANDROID_HOME="/android-sdk"
ENV PATH="/android-sdk/tools/bin:/android-sdk/build-tools:/android-sdk/platform-tools:${PATH}"

# SDK manager
RUN yes | sdkmanager --licenses
RUN sdkmanager "platforms;android-28" "platform-tools" "build-tools;28.0.3"

# Flutter
RUN wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.5.4-hotfix.2-stable.tar.xz \
 && tar xf flutter_linux_v1.5.4-hotfix.2-stable.tar.xz \
 && rm flutter_linux_v1.5.4-hotfix.2-stable.tar.xz
ENV PATH="/flutter/bin:${PATH}"
RUN flutter config --no-analytics

# Create a non-root default user
ARG USERNAME=some-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && chown -R $USERNAME:$USERNAME /flutter \
    && chown -R $USERNAME:$USERNAME /android-sdk
USER $USERNAME
