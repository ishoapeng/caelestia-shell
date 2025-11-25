#!/usr/bin/env bash
set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building and installing caelestia-shell...${NC}"

# Check for required tools
if ! command -v cmake &> /dev/null; then
    echo -e "${RED}Error: cmake is not installed${NC}"
    exit 1
fi

if ! command -v ninja &> /dev/null; then
    echo -e "${RED}Error: ninja is not installed${NC}"
    exit 1
fi

# Configure
echo -e "${YELLOW}Configuring build...${NC}"
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/

# Build
echo -e "${YELLOW}Building...${NC}"
cmake --build build

# Install
echo -e "${YELLOW}Installing (requires sudo)...${NC}"
sudo cmake --install build

echo -e "${GREEN}Installation complete!${NC}"
