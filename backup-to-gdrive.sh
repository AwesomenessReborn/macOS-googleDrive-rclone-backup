#!/bin/bash
# Backup Dev folder to Google Drive (excluding build artifacts)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Sync to Google Drive
echo -e "${GREEN}Syncing to Google Drive...${NC}"
rclone sync /Users/hareee234/Dev/projects \
  gdrive:Backups/Dev \
  --exclude-from "$EXCLUDE_FILE" \
  --progress \
  --create-empty-src-dirs \
  --transfers 4

echo ""
echo -e "${YELLOW}Backup statistics:${NC}"
rclone size gdrive:Backups/Dev

echo -e "${GREEN}Backup complete!${NC}"
