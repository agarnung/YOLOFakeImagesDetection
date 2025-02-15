#!/usr/bin/env bash

VENV=".yolofid"
PORT=5000

if [ -d "$VENV" ]; then
    source "$VENV/bin/activate"
    echo "✅ Virtual environment activated."
else
    echo "❌ Virtual environment '$VENV' not found."
    exit 1
fi

# Check if port 5000 is in use and kill the process
echo "🔍 Checking if port $PORT is in use..."
PID=$(lsof -t -i:$PORT)  # Get the PID of the process using the port

if [ -n "$PID" ]; then
    echo "🔴 Port $PORT is in use, terminating process with PID $PID..."
    kill -9 $PID  # Kill the process using the port
    sleep 1  # Wait a second to make sure the process has been stopped
else
    echo "🟢 Port $PORT is free."
fi

echo "🚀 Starting Flask server..."
python app.py --host=0.0.0.0 --port=$PORT &

# Wait 5 seconds to ensure Flask has started
for i in {1..5}; do
    echo -n "."
    sleep 1
done

# Open the web app in the default browser
echo "🌍 Opening the web application in the default browser..."

if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
    # For Linux or macOS, use the system's default browser
    xdg-open "http://127.0.0.1:$PORT" || open "http://127.0.0.1:$PORT" # xdg-open (Linux), open (macOS)
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # For Windows, use start to open the default browser
    start "http://127.0.0.1:$PORT" # For Windows
else
    echo "❌ Unsupported operating system for automatic browser opening."
    exit 1
fi

# Keep the script running until Flask is closed
wait
