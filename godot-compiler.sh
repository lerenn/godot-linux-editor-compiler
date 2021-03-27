#!/bin/bash

# Variables
################################################################################

# Variables
if [ -z "${THREADS}" ]; then THREADS=$(nproc); fi
if [ -z "${BINARY_BASE_DIR}" ]; then BINARY_BASE_DIR="${HOME}/.local/bin"; fi
if [ -z "${TEMPLATE_BASE_DIR}" ]; then TEMPLATE_BASE_DIR="${HOME}/.local/share/godot/templates"; fi
if [ -z "${PLATFORM}" ]; then PLATFORM=x11; fi
if [ -z "${GODOT_EDITOR}" ]; then GODOT_EDITOR=godot.${PLATFORM}.tools.64; fi

# Get godot path and go
GODOT_PATH=$1
if [ "${GODOT_PATH}" == "" ]; then
	echo "Please put the path to Godot source code as argument"
	exit 1
fi 
cd "${GODOT_PATH}"

# Godot Source Code
################################################################################

echo "# Update project"
git pull

# Linux Editor
################################################################################

echo "# Compile Editor for Linux"
scons -j${THREADS} platform=${PLATFORM}
cp -f ${GODOT_PATH}/bin/${GODOT_EDITOR} ${BINARY_BASE_DIR}/

# Get informations on Editor
################################################################################

echo "# Get informations from compiled editor"
COMPLETE_VERSION=$(${GODOT_PATH}/bin/${GODOT_EDITOR} --version)
echo "Complete version is ${COMPLETE_VERSION}"
VERSION=$(echo "${COMPLETE_VERSION}" | sed 's|.custom.*||')
echo "Version is '${VERSION}'"

echo "# Create Template directory"
TEMPLATE_DIR="${TEMPLATE_BASE_DIR}/${VERSION}"
mkdir -p ${TEMPLATE_DIR}
echo "Template directory is '${TEMPLATE_DIR}'"

# Templates for Linux
################################################################################

LINUX_BITS=( 32 64 )
for BITS in "${LINUX_BITS[@]}"; do
	echo "# Compile and install export templates for Linux ${BITS}bits"
	scons -j${THREADS} platform=${PLATFORM} tools=no target=release bits=${BITS}
	cp ${GODOT_PATH}/bin/godot.${PLATFORM}.opt.${BITS} ${TEMPLATE_DIR}/linux_${PLATFORM}_${BITS}_release
	scons -j${THREADS} platform=${PLATFORM} tools=no target=release_debug bits=${BITS}
	cp ${GODOT_PATH}/bin/godot.${PLATFORM}.opt.debug.${BITS} ${TEMPLATE_DIR}/linux_${PLATFORM}_${BITS}_debug
done

# Templates for Android
################################################################################

echo "# Compile and install export templates for Android"

# Set variables if not set
if [ -z "${ANDROID_SDK_ROOT}" ]; then ANDROID_SDK_ROOT=""; fi

# Release mode
scons -j${THREADS} platform=android target=release android_arch=armv7
scons -j${THREADS} platform=android target=release android_arch=arm64v8
scons -j${THREADS} platform=android target=release android_arch=x86
scons -j${THREADS} platform=android target=release android_arch=x86_64
# Debug mode
scons -j${THREADS} platform=android target=release_debug android_arch=armv7
scons -j${THREADS} platform=android target=release_debug android_arch=arm64v8
scons -j${THREADS} platform=android target=release_debug android_arch=x86
scons -j${THREADS} platform=android target=release_debug android_arch=x86_64
# Building the APK
cd platform/android/java
./gradlew generateGodotTemplates
cd ../../..
# Copy file to templates directory
cp ${GODOT_PATH}/bin/android_release.apk ${TEMPLATE_DIR}/
cp ${GODOT_PATH}/bin/android_debug.apk ${TEMPLATE_DIR}/

# Templates for Windows
################################################################################

echo "# Compile and install export templates for Windows"
echo "TODO"

# Templates for Web
################################################################################

echo "# Compile and install export templates for Web"
scons -j${THREADS} platform=javascript tools=no target=release javascript_eval=no
cp ${GODOT_PATH}/bin/godot.javascript.opt.zip ${TEMPLATE_DIR}/webassembly_release.zip
scons -j${THREADS} platform=javascript tools=no target=release_debug javascript_eval=no
cp ${GODOT_PATH}/bin/godot.javascript.opt.debug.zip ${TEMPLATE_DIR}/webassembly_debug.zip
