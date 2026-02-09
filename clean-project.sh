#!/bin/bash
# Clean build artifacts from a project before deletion

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <project-path>${NC}"
    echo -e "${YELLOW}Example: $0 /Users/hareee234/Dev/projects/old-project${NC}"
    exit 1
fi

PROJECT_PATH="$1"

if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Directory does not exist: $PROJECT_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}Checking project: $PROJECT_PATH${NC}"
echo ""

# Check size before
BEFORE=$(du -sh "$PROJECT_PATH" | cut -f1)
echo -e "${GREEN}Size before cleaning: $BEFORE${NC}"
echo ""

# Clean node_modules
if [ -d "$PROJECT_PATH/node_modules" ]; then
    echo -e "${YELLOW}Removing node_modules...${NC}"
    rm -rf "$PROJECT_PATH/node_modules"
fi

# Clean Python venvs
find "$PROJECT_PATH" -type d \( -name ".venv" -o -name "venv" \) -exec rm -rf {} + 2>/dev/null

# Clean build folders
find "$PROJECT_PATH" -type d \( -name "build" -o -name "dist" -o -name ".next" -o -name "out" \) -exec rm -rf {} + 2>/dev/null

# Clean caches
find "$PROJECT_PATH" -type d \( -name "__pycache__" -o -name ".pytest_cache" \) -exec rm -rf {} + 2>/dev/null

# Check size after
AFTER=$(du -sh "$PROJECT_PATH" | cut -f1)
echo ""
echo -e "${GREEN}Size after cleaning: $AFTER${NC}"
echo -e "${YELLOW}Project is now clean and ready to delete (backed up in Google Drive)${NC}"
