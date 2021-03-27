FROM ubuntu:20.04

# Install dependencies
################################################################################

# Update lists
RUN apt update

# Editor --------------------------------------------------------------------- #

# Install dependencies
RUN DEBIAN_FRONTEND='noninteractive' apt install -y \
	build-essential scons pkg-config libx11-dev libxcursor-dev \
	libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev \
	libpulse-dev libudev-dev libxi-dev libxrandr-dev yasm

# Web Templates -------------------------------------------------------------- #

# Install dependencies
RUN DEBIAN_FRONTEND='noninteractive' apt install -y git scons python3 && \
	git clone https://github.com/emscripten-core/emsdk.git /usr/src/emsdk && \
	cd /usr/src/emsdk && ./emsdk install latest && ./emsdk activate latest

# Android Templates ---------------------------------------------------------- #

# Set variables for Android
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_NDK_ROOT /opt/android-sdk/ndk-bundle/

# Install dependencies
RUN DEBIAN_FRONTEND='noninteractive' apt install -y scons python3 wget \
	gradle openjdk-8-jdk
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip && \
	unzip commandlinetools-linux-6200805_latest.zip && rm commandlinetools-linux-6200805_latest.zip && \
	mkdir -p /opt/android-sdk && mv tools /opt/android-sdk/
RUN	wget https://dl.google.com/android/repository/android-ndk-r21b-linux-x86_64.zip && \
	unzip android-ndk-r21b-linux-x86_64.zip && rm android-ndk-r21b-linux-x86_64.zip && \
	mkdir -p /opt/android-sdk && mv android-ndk-r21b /opt/android-sdk/ndk-bundle

# Accept licenses and install gradle
RUN yes | /opt/android-sdk/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses && \
	gradle

# Set links for compatibility
RUN mkdir -p /opt/android-sdk/cmdline-tools/ && \
	ln -s /opt/android-sdk/tools/ /opt/android-sdk/cmdline-tools/latest

# Linux 32bits Templates ----------------------------------------------------- #

# Update to 32 bits architcture
RUN dpkg --add-architecture i386 && \
	apt update

# Install dependencies
RUN DEBIAN_FRONTEND='noninteractive' apt install -y \
	libc6-dev:i386 gcc-multilib g++-multilib \
	libx11-dev:i386 libxcursor-dev:i386 \
	libxinerama-dev:i386 libgl1-mesa-dev:i386 libglu-dev:i386 libasound2-dev:i386 \
	libpulse-dev:i386 libudev-dev:i386 libxi-dev:i386 libxrandr-dev:i386

# Prepare for source code and compilation
################################################################################

# Make the recipient a volume
VOLUME /godot

# Prepare branch number
ENV GODOT_BRANCH 3.2
ENV PLATFORM x11

# Volume for output results
VOLUME /output

# Copy scripts 
################################################################################

# Copy docker specific scripts
COPY docker /docker

# Copy godot-compiler script 
COPY godot-compiler.sh /docker/scripts

# Command file 
CMD ["bash", "docker/scripts/entrypoint.sh"]