FROM ghcr.io/cirruslabs/flutter:stable

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-8-jdk \
    wget \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Android SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" \
    "extras;android;m2repository" "extras;google;m2repository"

# Install useful global packages
RUN flutter config --no-analytics && \
    flutter precache && \
    flutter doctor && \
    dart pub global activate devtools && \
    dart pub global activate fvm

# Set up Android SDK path
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/platform-tools

# Warm up Flutter
RUN flutter doctor -v 