#!/bin/bash

LOG_FILE="logs/validate.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

mkdir -p logs

echo "[$TIMESTAMP] Starting validation..." >> "$LOG_FILE"

if [ ! -d "src" ]; then
    echo "[$TIMESTAMP] ERROR: src/ directory does not exist." >> "$LOG_FILE"
    exit 1
fi

if ! jq empty config.json >/dev/null 2>&1; then
    echo "[$TIMESTAMP] ERROR: config.json is invalid." >> "$LOG_FILE"
    exit 1
fi

echo "[$TIMESTAMP] Validation passed ✅" >> "$LOG_FILE"
