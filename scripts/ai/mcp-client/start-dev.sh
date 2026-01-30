#!/bin/bash

# Simple MCP Chat Client - Development Start Script
# This script starts both backend and frontend servers with logging
# Usage: ./start-dev.sh [local|proxy|custom] [custom-api-url]

set -e

# Parse arguments
MODE=${1:-local}
CUSTOM_API_URL=$2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create logs directory
mkdir -p logs

# Function to get the absolute path of the project's virtual environment
get_project_venv_path() {
    echo "$(pwd)/backend/venv"
}

# Function to check if we're in the correct virtual environment
is_correct_venv() {
    local project_venv_path=$(get_project_venv_path)
    if [ -n "$VIRTUAL_ENV" ] && [ "$VIRTUAL_ENV" = "$project_venv_path" ]; then
        return 0
    else
        return 1
    fi
}

# Function to activate the project's virtual environment
activate_project_venv() {
    local venv_path="backend/venv"
    
    if [ ! -d "$venv_path" ]; then
        echo -e "${RED}Error: Project virtual environment not found at $venv_path${NC}"
        echo "Please run ./setup.sh first to create the virtual environment"
        exit 1
    fi
    
    # Detect OS for activation script
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        source "$venv_path/Scripts/activate"
    else
        source "$venv_path/bin/activate"
    fi
}

# Function to cleanup background processes
cleanup() {
    echo -e "\n${YELLOW}Stopping servers...${NC}"
    if [ -f logs/backend.pid ]; then
        PID=$(cat logs/backend.pid)
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            echo -e "${GREEN}Backend server stopped${NC}"
        fi
        rm -f logs/backend.pid
    fi
    
    if [ -f logs/frontend.pid ]; then
        PID=$(cat logs/frontend.pid)
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            echo -e "${GREEN}Frontend server stopped${NC}"
        fi
        rm -f logs/frontend.pid
    fi
    
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Validate mode
case $MODE in
    "local"|"proxy"|"custom")
        ;;
    *)
        echo -e "${RED}Error: Unknown mode '$MODE'${NC}"
        echo ""
        echo "Usage: ./start-dev.sh [mode] [custom-api-url]"
        echo ""
        echo "Modes:"
        echo "  local   - Local development (default)"
        echo "  proxy   - Workshop/Kubernetes proxy mode"
        echo "  custom  - Custom backend URL"
        echo ""
        echo "Examples:"
        echo "  ./start-dev.sh"
        echo "  ./start-dev.sh local"
        echo "  ./start-dev.sh proxy"
        echo "  ./start-dev.sh custom https://my-backend.com/api"
        exit 1
        ;;
esac

# Validate custom mode
if [ "$MODE" = "custom" ] && [ -z "$CUSTOM_API_URL" ] && [ -z "$VITE_API_BASE_URL" ]; then
    echo -e "${RED}Error: Custom mode requires API URL${NC}"
    echo "Usage: ./start-dev.sh custom https://your-backend-url/api"
    echo "   or: VITE_API_BASE_URL=https://your-backend-url/api ./start-dev.sh custom"
    exit 1
fi

echo -e "${BLUE}Simple MCP Chat Client - Development Environment${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e "${YELLOW}Mode: $MODE${NC}"
if [ "$MODE" = "custom" ]; then
    if [ -n "$CUSTOM_API_URL" ]; then
        echo -e "${YELLOW}Custom API: $CUSTOM_API_URL${NC}"
    elif [ -n "$VITE_API_BASE_URL" ]; then
        echo -e "${YELLOW}Custom API: $VITE_API_BASE_URL${NC}"
    fi
fi
echo ""

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed or not in PATH${NC}"
    exit 1
fi

# Check if Node.js is available
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed or not in PATH${NC}"
    exit 1
fi

# Virtual Environment Management
echo -e "${YELLOW}Managing Python virtual environment...${NC}"

if is_correct_venv; then
    echo -e "${GREEN}✅ Already in correct project virtual environment${NC}"
else
    if [ -n "$VIRTUAL_ENV" ]; then
        echo -e "${YELLOW}⚠️  Currently in different virtual environment: $VIRTUAL_ENV${NC}"
        echo "Deactivating current virtual environment..."
        deactivate 2>/dev/null || true
    fi
    
    echo "Activating project virtual environment..."
    activate_project_venv
    echo -e "${GREEN}✅ Project virtual environment activated${NC}"
fi

# Verify we have the required packages
if ! python -c "import fastapi, uvicorn" 2>/dev/null; then
    echo -e "${RED}Error: Required backend packages not found in virtual environment${NC}"
    echo "Please run ./setup.sh to install dependencies"
    exit 1
fi

echo ""

# Start Backend Server
echo -e "${YELLOW}Starting backend server...${NC}"
cd backend
# Use python from activated venv (should be in PATH after activation)
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8002 > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > ../logs/backend.pid
cd ..

# Wait a moment for backend to start
sleep 2

# Check if backend started successfully
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}Failed to start backend server. Check logs/backend.log${NC}"
    exit 1
fi

echo -e "${GREEN}Backend server started (PID: $BACKEND_PID)${NC}"
echo -e "  URL: http://localhost:8002"
echo -e "  Logs: logs/backend.log"

# Start Frontend Server
echo -e "${YELLOW}Starting frontend server...${NC}"
cd frontend

# Set environment variables based on mode
case $MODE in
    "proxy")
        export VITE_USE_PROXY=true
        npm run dev:proxy > ../logs/frontend.log 2>&1 &
        ;;
    "custom")
        if [ -n "$CUSTOM_API_URL" ]; then
            export VITE_API_BASE_URL="$CUSTOM_API_URL"
        fi
        npm run dev:custom > ../logs/frontend.log 2>&1 &
        ;;
    *)
        npm run dev > ../logs/frontend.log 2>&1 &
        ;;
esac

FRONTEND_PID=$!
echo $FRONTEND_PID > ../logs/frontend.pid
cd ..

# Wait a moment for frontend to start
sleep 3

# Check if frontend started successfully
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo -e "${RED}Failed to start frontend server. Check logs/frontend.log${NC}"
    cleanup
    exit 1
fi

echo -e "${GREEN}Frontend server started (PID: $FRONTEND_PID)${NC}"
case $MODE in
    "proxy")
        echo -e "  URL: http://localhost:5173 (or next available port)"
        echo -e "  Mode: Proxy - API requests proxied to backend"
        ;;
    "custom")
        echo -e "  URL: http://localhost:5173 (or next available port)"
        if [ -n "$CUSTOM_API_URL" ]; then
            echo -e "  API: $CUSTOM_API_URL"
        elif [ -n "$VITE_API_BASE_URL" ]; then
            echo -e "  API: $VITE_API_BASE_URL"
        fi
        ;;
    *)
        echo -e "  URL: http://localhost:5173 (or next available port)"
        echo -e "  API: http://localhost:8002/api"
        ;;
esac
echo -e "  Logs: logs/frontend.log"

echo ""
echo -e "${GREEN}Both servers are running in $MODE mode!${NC}"
echo -e "${BLUE}Press Ctrl+C to stop both servers${NC}"
echo ""
echo -e "Logs are being written to:"
echo -e "  Backend:  logs/backend.log"
echo -e "  Frontend: logs/frontend.log"
echo ""
echo -e "You can monitor logs in real-time with:"
echo -e "  ${YELLOW}tail -f logs/backend.log${NC}"
echo -e "  ${YELLOW}tail -f logs/frontend.log${NC}"

# Wait indefinitely (servers run in background)
wait