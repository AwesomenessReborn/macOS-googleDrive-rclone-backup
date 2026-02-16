#!/bin/bash
# Backup Dev folder to Google Drive (excluding build artifacts)

# Ensure Homebrew binaries are in PATH (required for cron jobs)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup started"
echo -e "${GREEN}Starting Dev folder backup to Google Drive...${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXCLUDE_FILE="$SCRIPT_DIR/.rclone-exclude"

if [ ! -f "$EXCLUDE_FILE" ]; then
    echo -e "${RED}Error: Exclusion file not found: $EXCLUDE_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}Using exclusion patterns from: $EXCLUDE_FILE${NC}"

# Check if rclone is installed
if ! command -v rclone &> /dev/null; then
    echo -e "${YELLOW}Installing rclone...${NC}"
    brew install rclone
fi

STATUS_FILE="$SCRIPT_DIR/last-backup-status"

# Sync to Google Drive
echo -e "${GREEN}Syncing to Google Drive...${NC}"
rclone sync /Users/hareee234/Dev/projects \
  gdrive:Backups/Dev \
  --exclude-from "$EXCLUDE_FILE" \
  --progress \
  --create-empty-src-dirs \
  --transfers 4

EXIT_CODE=$?

# Write status file for terminal display
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
FILE_COUNT=$(rclone size gdrive:Backups/Dev --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['count'])" 2>/dev/null || echo "?")
TOTAL_SIZE=$(rclone size gdrive:Backups/Dev --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); b=d['bytes']; print(f'{b/1024**3:.2f} GB')" 2>/dev/null || echo "?")

if [ $EXIT_CODE -eq 0 ]; then
  echo "status=success" > "$STATUS_FILE"
else
  echo "status=failed" > "$STATUS_FILE"
fi
echo "time=$TIMESTAMP" >> "$STATUS_FILE"
echo "files=$FILE_COUNT" >> "$STATUS_FILE"
echo "size=$TOTAL_SIZE" >> "$STATUS_FILE"

echo ""
echo -e "${YELLOW}Backup statistics:${NC}"
rclone size gdrive:Backups/Dev

echo -e "${GREEN}Backup complete!${NC}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup finished"
