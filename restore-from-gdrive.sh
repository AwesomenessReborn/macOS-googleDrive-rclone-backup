#!/bin/bash
# Restore projects from Google Drive backup

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 <project-name>${NC}"
    echo -e "${YELLOW}   or: $0 --all (restore everything)${NC}"
    echo ""
    echo -e "${GREEN}Available projects in backup:${NC}"
    rclone lsf gdrive:Backups/Dev --dirs-only
    exit 1
fi

if [ "$1" = "--all" ]; then
    echo -e "${YELLOW}Restoring ALL projects from Google Drive...${NC}"
    rclone sync gdrive:Backups/Dev /Users/hareee234/Dev/projects --progress
    echo -e "${GREEN}Restore complete! Don't forget to:${NC}"
    echo "  1. Reinstall dependencies (npm install, pip install, etc.)"
    echo "  2. Pull latest from git if needed"
else
    PROJECT_NAME="$1"
    echo -e "${YELLOW}Restoring project: $PROJECT_NAME${NC}"
    rclone copy "gdrive:Backups/Dev/$PROJECT_NAME" "/Users/hareee234/Dev/projects/$PROJECT_NAME" --progress
    echo -e "${GREEN}Restore complete!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  cd /Users/hareee234/Dev/projects/$PROJECT_NAME"
    echo "  # Reinstall dependencies if needed:"
    echo "  npm install    # for Node projects"
    echo "  pip install -r requirements.txt  # for Python projects"
fi
