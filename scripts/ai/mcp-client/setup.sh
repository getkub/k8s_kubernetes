#!/bin/bash

# Simple MCP Client Setup Script
# This script sets up both the backend and frontend for the Simple MCP Client

set -e  # Exit on any error

echo "🤖 Simple MCP Client Setup"
echo "=========================="

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    OS="windows"
fi

echo "Detected OS: $OS"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Python
if ! command_exists python3; then
    echo "❌ Python 3 is required but not installed."
    echo "Please install Python 3.8+ and try again."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo "✅ Python $PYTHON_VERSION found"

# Check Node.js
if ! command_exists node; then
    echo "❌ Node.js is required but not installed."
    echo "Please install Node.js 16+ and try again."
    exit 1
fi

NODE_VERSION=$(node --version)
echo "✅ Node.js $NODE_VERSION found"

# Check npm
if ! command_exists npm; then
    echo "❌ npm is required but not installed."
    echo "Please install npm and try again."
    exit 1
fi

NPM_VERSION=$(npm --version)
echo "✅ npm $NPM_VERSION found"

echo ""

# Backend setup
echo "🐍 Setting up Backend..."
echo "------------------------"

# Check if currently in a virtual environment
if [ -n "$VIRTUAL_ENV" ]; then
    echo "⚠️  Currently in virtual environment: $VIRTUAL_ENV"
    echo "Deactivating current virtual environment..."
    deactivate 2>/dev/null || true
    echo "✅ Deactivated current virtual environment"
fi

cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
else
    echo "✅ Virtual environment already exists"
fi

# Activate virtual environment
echo "Activating project virtual environment..."
if [[ "$OS" == "windows" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi
echo "✅ Virtual environment activated"

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip
echo "✅ pip upgraded"

# Install requirements
if [ -f "requirements.txt" ]; then
    echo "Installing Python dependencies..."
    pip install -r requirements.txt
    echo "✅ Python dependencies installed"
    
    # Verify key backend packages
    echo "Verifying backend package installation..."
    MISSING_PACKAGES=""
    for package in "fastapi" "uvicorn" "pydantic" "httpx"; do
        if ! python -c "import $package" 2>/dev/null; then
            MISSING_PACKAGES="$MISSING_PACKAGES $package"
        fi
    done
    
    if [ -n "$MISSING_PACKAGES" ]; then
        echo "❌ Missing backend packages:$MISSING_PACKAGES"
        exit 1
    fi
    
    PACKAGE_COUNT=$(pip list | grep -v "^Package\|^---" | wc -l)
    echo "✅ Backend verification complete ($PACKAGE_COUNT packages installed)"
else
    echo "❌ requirements.txt not found in backend directory"
    exit 1
fi

# Create logs directory if it doesn't exist
if [ ! -d "logs" ]; then
    mkdir logs
    echo "✅ Logs directory created"
fi

# Create database if it doesn't exist
echo "Initializing database..."
python -c "from app.core.database import Database; db = Database(); print('✅ Database initialized')"

cd ..

echo ""

# Frontend setup
echo "⚛️  Setting up Frontend..."
echo "-------------------------"

cd frontend

# Install dependencies
echo "Installing Node.js dependencies..."
npm install
echo "✅ Node.js dependencies installed"

# Verify key frontend packages
echo "Verifying frontend package installation..."
MISSING_PACKAGES=""
for package in "react" "vite" "typescript" "@radix-ui/react-accordion"; do
    if ! npm list "$package" >/dev/null 2>&1; then
        MISSING_PACKAGES="$MISSING_PACKAGES $package"
    fi
done

if [ -n "$MISSING_PACKAGES" ]; then
    echo "❌ Missing frontend packages:$MISSING_PACKAGES"
    exit 1
fi

PACKAGE_COUNT=$(npm list --depth=0 2>/dev/null | grep -c "├──\|└──" || echo "0")
echo "✅ Frontend verification complete ($PACKAGE_COUNT direct dependencies installed)"

cd ..

echo ""

# Final setup
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Your Simple MCP Client is now ready to use!"
echo ""
echo "🚀 Quick Start Options:"
echo ""
echo "Local Development (default):"
echo "   ./start-dev.sh"
echo ""
echo "Workshop/Kubernetes environments (Instruqt, etc.):"
echo "   ./start-dev.sh proxy"
echo ""
echo "Custom backend URL:"
echo "   ./start-dev.sh custom https://your-backend-url/api"
echo ""
echo "The start script will:"
echo "• Start both backend and frontend servers"
echo "• Handle logging to logs/ directory"  
echo "• Show live status and URLs"
echo "• Stop gracefully with Ctrl+C"
echo ""
echo "📖 For detailed documentation, see README.md"
echo ""
echo "📝 Next steps:"
echo "1. Run one of the start commands above"
echo "2. Open your browser to the displayed frontend URL"
echo "3. Configure an LLM provider in Settings"
echo "4. Add MCP servers in Settings"
echo "5. Start chatting with your AI assistant!"