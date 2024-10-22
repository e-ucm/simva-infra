#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Variables
PLUGIN_NAME="LimeSuveyStatusWebhookPlugin"
PLUGIN_SRC="$STACK_HOME/plugins/$PLUGIN_NAME"  # Local plugin directory
PLUGIN_DEST="$SIMVA_DATA_HOME/limesurvey/data/plugins/"  # Destination

# Step 1: Copy the plugin to the LimeSurvey container
echo "Copying plugin to LimeSurvey container plugin folder..."
cp -r $PLUGIN_SRC $PLUGIN_DEST
