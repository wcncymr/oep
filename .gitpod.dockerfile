FROM gitpod/workspace-full-vnc


ENV ANDROID_HOME=/home/gitpod/android-sdk \
# Get the latest version from https://developer.android.com/studio/index.html
    ANDROID_SDK_TOOLS_VERSION=4333796 \
    ANDROID_NDK=/home/gitpod/android-ndk \
# Get the latest version from https://developer.android.com/ndk/downloads/index.html
    ANDROID_NDK_VERSION=19\
    FLUTTER_HOME=/home/gitpod/flutter \
    FLUTTER_VERSION=v1.2.1-stable \
    PATH=/usr/lib/dart/bin:$FLUTTER_HOME/bin:$ANDROID_HOME/tools/bin:$PATH

ENV ANDROID_SDK_HOME="$ANDROID_HOME"
ENV ANDROID_NDK_HOME="$ANDROID_NDK/android-ndk-r$ANDROID_NDK_VERSION"
ENV JAVA_HOME=/home/gitpod/.sdkman/candidates/java/current

USER root

RUN curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list && \
    apt-get update && \
    apt-get -y install libpulse0 build-essential dart libkrb5-dev gcc make gradle android-tools-adb android-tools-fastboot && \
    apt-get clean && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*;

USER gitpod

# Install Android SDK
RUN echo "Installing sdk tools ${ANDROID_SDK_TOOLS_VERSION}" && \
    wget --quiet --output-document=sdk-tools.zip \
        "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip" && \
    mkdir --parents "$ANDROID_HOME" && \
    unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
    rm --force sdk-tools.zip
RUN echo "Installing ndk r${ANDROID_NDK_VERSION}" && \
    wget --quiet --output-document=android-ndk.zip \
    "http://dl.google.com/android/repository/android-ndk-r${ANDROID_NDK_VERSION}-linux-x86_64.zip" && \
    mkdir --parents "$ANDROID_NDK_HOME" && \
    unzip -q android-ndk.zip -d "$ANDROID_NDK" && \
    rm --force android-ndk.zip

# Install SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.
RUN mkdir --parents "$ANDROID_HOME/.android/" && \
    echo '### User Sources for Android SDK Manager' > \
        "$ANDROID_HOME/.android/repositories.cfg" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager --licenses > /dev/null && \
    echo "Installing platforms" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platforms;android-28" \
        "platforms;android-27" \
        "platforms;android-26" \
        "platforms;android-25" \
        "platforms;android-24" \
        "platforms;android-23" \
        "platforms;android-22" \
        "platforms;android-21" \
        "platforms;android-20" \
        "platforms;android-19" \
        "platforms;android-18" \
        "platforms;android-17" \
        "platforms;android-16" > /dev/null

RUN echo "Installing platform tools " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platform-tools" > /dev/null
RUN echo "Installing build tools " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "build-tools;28.0.3" "build-tools;28.0.2" \
        "build-tools;27.0.3" "build-tools;27.0.2" "build-tools;27.0.1" \
        "build-tools;26.0.2" "build-tools;26.0.1" "build-tools;26.0.0" \
        "build-tools;25.0.3" "build-tools;25.0.2" \
        "build-tools;25.0.1" "build-tools;25.0.0" \
        "build-tools;24.0.3" "build-tools;24.0.2" \
        "build-tools;24.0.1" "build-tools;24.0.0" > /dev/null
RUN echo "Installing build tools " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "build-tools;23.0.3" "build-tools;23.0.2" "build-tools;23.0.1" \
        "build-tools;22.0.1" \
        "build-tools;21.1.2" \
        "build-tools;20.0.0" \
        "build-tools;19.1.0" \
        "build-tools;18.1.1" \
        "build-tools;17.0.0" > /dev/null
RUN echo "Installing extras " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "extras;android;m2repository" \
        "extras;google;m2repository" > /dev/null
RUN echo "Installing play services " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "extras;google;google_play_services" \
        "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
        "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" > /dev/null
RUN echo "Installing Google APIs" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "add-ons;addon-google_apis-google-24" \
        "add-ons;addon-google_apis-google-23" \
        "add-ons;addon-google_apis-google-22" \
        "add-ons;addon-google_apis-google-21" \
        "add-ons;addon-google_apis-google-19" \
        "add-ons;addon-google_apis-google-18" \
        "add-ons;addon-google_apis-google-17" \
        "add-ons;addon-google_apis-google-16" > /dev/null
RUN echo "Installing emulator " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager "emulator" > /dev/null

RUN echo "Installing system images " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "system-images;android-25;google_apis;x86_64" > /dev/null

# Install Flutter sdk
RUN cd /home/gitpod && \
  wget -qO flutter_sdk.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz && \
  tar -xvf flutter_sdk.tar.xz && \
  rm flutter_sdk.tar.xz
