#!/bin/bash
# Check disk usage of Dev projects

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Dev Projects Disk Usage ===${NC}\n"

# Overall usage
echo -e "${YELLOW}Total Dev folder:${NC}"
du -sh /Users/hareee234/Dev/projects
echo ""

# Top-level projects
echo -e "${YELLOW}Projects breakdown:${NC}"
du -sh /Users/hareee234/Dev/projects/*/ 2>/dev/null | sort -hr
echo ""

# Find large node_modules
echo -e "${YELLOW}Large node_modules (can be deleted & reinstalled):${NC}"
find /Users/hareee234/Dev/projects -name "node_modules" -type d -exec du -sh {} \; 2>/dev/null | sort -hr | head -10
echo ""

# Find large .venv
echo -e "${YELLOW}Large Python venvs (can be deleted & recreated):${NC}"
find /Users/hareee234/Dev/projects -name ".venv" -o -name "venv" -type d -exec du -sh {} \; 2>/dev/null | sort -hr | head -10
echo ""

# Available space
echo -e "${YELLOW}Available disk space:${NC}"
df -h /Users/hareee234/Dev | tail -1
