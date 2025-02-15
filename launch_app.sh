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

echo "🌍 Opening Firefox at http://127.0.0.1:$PORT/"
firefox "http://127.0.0.1:$PORT/" &

# Keep the script running until Flask is closed
wait
