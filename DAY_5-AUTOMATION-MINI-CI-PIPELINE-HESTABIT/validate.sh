set -e

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/validate.log"

mkdir -p "$LOG_DIR"

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting validation" >> "$LOG_FILE"

if [ ! -d "src" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: src/ directory missing" >> "$LOG_FILE"
  exit 1
fi

if [ ! -f "config.json" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: config.json missing" >> "$LOG_FILE"
  exit 1
fi

jq . config.json >/dev/null 2>&1 || {
  echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: Invalid config.json" >> "$LOG_FILE"
  exit 1
}

echo "$(date '+%Y-%m-%d %H:%M:%S') Validation successful" >> "$LOG_FILE"
