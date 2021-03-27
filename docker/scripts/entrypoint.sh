#!/bin/bash

# Variables
GODOT_SRC_CODE=/godot

# Check if Godot is present or not
if [ -z "$(ls -A ${GODOT_SRC_CODE})" ]; then
   echo "Godot directory is empty, cloning..."
   git clone https://github.com/godotengine/godot /godot
fi                                      

# Get to the correct version of godot
cd ${GODOT_SRC_CODE}
git checkout ${GODOT_BRANCH}

# Update source code
git pull

# Export Docker-specific variables 
export TEMPLATE_BASE_DIR=/output/templates
export BINARY_BASE_DIR=/output
source /usr/src/emsdk/emsdk_env.sh

# Execute script
nice -n 19 bash /docker/scripts/godot-compiler.sh ${GODOT_SRC_CODE}