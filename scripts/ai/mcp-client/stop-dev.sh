#!/bin/bash

# Simple MCP Chat Client - Development Stop Script
# This script stops both backend and frontend servers

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Stopping development servers...${NC}"

# Stop backend server
if [ -f logs/backend.pid ]; then
    PID=$(cat logs/backend.pid)
    if kill -0 $PID 2>/dev/null; then
        kill $PID
        echo -e "${GREEN}Backend server stopped (PID: $PID)${NC}"
    else
        echo -e "${YELLOW}Backend server was not running${NC}"
    fi
    rm -f logs/backend.pid
else
    echo -e "${YELLOW}No backend PID file found${NC}"
fi

# Stop frontend server
if [ -f logs/frontend.pid ]; then
    PID=$(cat logs/frontend.pid)
    if kill -0 $PID 2>/dev/null; then
        kill $PID
        echo -e "${GREEN}Frontend server stopped (PID: $PID)${NC}"
    else
        echo -e "${YELLOW}Frontend server was not running${NC}"
    fi
    rm -f logs/frontend.pid
else
    echo -e "${YELLOW}No frontend PID file found${NC}"
fi

# Clean up any remaining processes (fallback)
pkill -f "uvicorn app.main:app" 2>/dev/null && echo -e "${GREEN}Cleaned up any remaining backend processes${NC}"
pkill -f "vite" 2>/dev/null && echo -e "${GREEN}Cleaned up any remaining frontend processes${NC}"

echo -e "${GREEN}All servers stopped${NC}"