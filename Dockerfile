FROM mono:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install software-properties-common -y && mkdir -p /usr/share/man/man1 && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    apt-transport-https \
    ca-certificates \
    dirmngr \
    gnupg \
    wget
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -; \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/; \
    apt update; \
    apt install adoptopenjdk-8-hotspot -y

RUN java -version

ENV GODOT_VERSION "3.3.1"
ENV ANDROID_COMPILE_SDK 29
ENV ANDROID_BUILD_TOOLS 30.0.3

ENV RELEASE_NAME "stable"

# This is only needed for non-stable builds (alpha, beta, RC)
# e.g. SUBDIR "/beta3"
# Use an empty string "" when the RELEASE_NAME is "stable"
ENV SUBDIR ""

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    && wget -N https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}${SUBDIR}/mono/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_headless_64.zip \
    && wget -N https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}${SUBDIR}/mono/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_export_templates.tpz \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/templates/${GODOT_VERSION}.${RELEASE_NAME}.mono \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_headless_64.zip \
    && mv Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_headless_64/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_headless.64 /usr/local/bin/godot \
    && mv Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_headless_64/GodotSharp /usr/local/bin/GodotSharp \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.${RELEASE_NAME}.mono \
    && rm -f Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_export_templates.tpz Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_headless_64.zip \
&& wget https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip \
 && unzip -d android-sdk commandlinetools-linux-6858069_latest.zip \
 && mv android-sdk /opt/android-sdk \
&& yes | /opt/android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android-sdk/cmdline-tools --licenses \
&& /opt/android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android-sdk/cmdline-tools "platform-tools" "platforms;android-$ANDROID_COMPILE_SDK" "build-tools;${ANDROID_BUILD_TOOLS}" \
&& apt-get remove wget unzip -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && apt autoremove -y

RUN godot -e -v -q \
    && echo 'export/android/android_sdk_path = "/opt/android-sdk/cmdline-tools"' >> ./root/.config/godot/editor_settings-3.tres
