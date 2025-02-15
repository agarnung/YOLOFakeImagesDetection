#!/usr/bin/env bash

# Virtual environment directory name
VENV_DIR=".yolofid"

echo "Setting up the virtual environment for the project..."

# Create the virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
else
    echo "The virtual environment already exists."
fi

# Detect the operating system and activate the virtual environment
if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
    ACTIVATE_CMD="source $VENV_DIR/bin/activate"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    ACTIVATE_CMD="source $VENV_DIR/Scripts/activate"
else
    echo "Unsupported operating system for automatic virtual environment activation."
    exit 1
fi

# Print the command for the user to run manually if not using 'source script.sh'
echo "Running: $ACTIVATE_CMD"
eval "$ACTIVATE_CMD"

# Install dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "Installing dependencies from requirements.txt..."
    pip install --upgrade pip
    pip install -r requirements.txt
else
    echo "No requirements.txt file found, run pyreqs if needed."
fi

echo "Environment setup and activated."
