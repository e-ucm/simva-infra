#!/usr/bin/env bash
mkdir "${SIMVA_DATA_HOME}/limesurvey/data/tmp/runtime/"
# Set rights for www-data to Limesurvey data folder
chown -R 33:33 "${SIMVA_DATA_HOME}/limesurvey/data/"
chmod -R 755 "${SIMVA_DATA_HOME}/limesurvey/data/"