#!/bin/bash
# Complete Jot Setup with API Key Generation
# Sets up PM2, creates owner account, and generates API key automatically

set -e

# Configuration
JOT_URL="http://localhost:3210"
JOT_PORT=3210
JOT_DATA_DIR="$HOME/jot-data"
JOT_PASSWORD="your-secure-password-here-please-change"
API_KEY_LABEL="opencode-skill"

echo "🚀 Complete Jot Setup for OpenCode Skills..."
echo ""

# Step 1: Install dependencies
echo "📦 Checking dependencies..."
if ! command -v npm &> /dev/null; then
    echo "❌ Node.js/npm not found. Please install Node.js 18+ first."
    exit 1
fi

if ! command -v pm2 &> /dev/null; then
    echo "📥 Installing PM2..."
    npm install -g pm2
else
    echo "✅ PM2 already installed"
fi

if ! command -v jot &> /dev/null; then
    echo "📥 Installing Jot CLI..."
    npm install -g @mariozechner/jot
else
    echo "✅ Jot CLI already installed"
fi

# Step 2: Create data directory
echo "📁 Setting up data directory..."
mkdir -p "$JOT_DATA_DIR/logs"

# Step 3: Start Jot with PM2
echo "🚀 Starting Jot server..."
pm2 start "jot serve --port=${JOT_PORT} --data=${JOT_DATA_DIR}" --name jot || pm2 restart jot

# Wait for Jot to be ready
echo "⏳ Waiting for Jot server to start..."
sleep 5

# Verify Jot is running
if ! curl -s "$JOT_URL" > /dev/null; then
    echo "❌ Jot server failed to start. Check logs with: pm2 logs jot"
    exit 1
fi

echo "✅ Jot server is running at $JOT_URL"

# Step 4: Create owner account and API key
echo "🔐 Setting up authentication..."
COOKIES_FILE="/tmp/jot-cookies-$(date +%s).txt"

# Set up owner account
SETUP_RESPONSE=$(curl -s -X POST "${JOT_URL}/api/auth/setup" \
  -H "Content-Type: application/json" \
  -d "{\"password\":\"${JOT_PASSWORD}\",\"confirmPassword\":\"${JOT_PASSWORD}\"}")

DEVICE_TOKEN=$(echo "$SETUP_RESPONSE" | jq -r '.token')

if [ "$DEVICE_TOKEN" == "null" ] || [ -z "$DEVICE_TOKEN" ]; then
    echo "⚠️ Owner account may already exist or setup failed. Trying login..."
    # Try to get existing session
    LOGIN_RESPONSE=$(curl -s -c "$COOKIES_FILE" -X POST "${JOT_URL}/api/auth/login" \
      -H "Content-Type: application/json" \
      -d "{\"password\":\"${JOT_PASSWORD}\"}")
    
    if ! echo "$LOGIN_RESPONSE" | jq -e '.ok' > /dev/null; then
        echo "❌ Failed to authenticate. Response: $LOGIN_RESPONSE"
        exit 1
    fi
else
    echo "✅ Owner account created"
    # Exchange device token for session
    curl -s -c "$COOKIES_FILE" -X POST "${JOT_URL}/api/auth/token" \
      -H "Content-Type: application/json" \
      -d "{\"token\":\"${DEVICE_TOKEN}\"}" > /dev/null
fi

# Step 5: Create API key
echo "🔑 Creating API key..."
KEY_RESPONSE=$(curl -s -b "$COOKIES_FILE" -X POST "${JOT_URL}/api/keys" \
  -H "Content-Type: application/json" \
  -d "{\"label\":\"${API_KEY_LABEL}\"}")

API_KEY=$(echo "$KEY_RESPONSE" | jq -r '.key')
KEY_ID=$(echo "$KEY_RESPONSE" | jq -r '.id')

if [ "$API_KEY" == "null" ] || [ -z "$API_KEY" ]; then
    echo "❌ Failed to create API key. Response: $KEY_RESPONSE"
    rm -f "$COOKIES_FILE"
    exit 1
fi

# Clean up
rm -f "$COOKIES_FILE"

# Step 6: Register CLI
echo "📝 Registering Jot CLI..."
jot register local "$JOT_URL" "$API_KEY"

# Verify registration
if jot local list &> /dev/null; then
    echo "✅ CLI registration successful"
else
    echo "⚠️ CLI registration may have issues, but API key is valid"
fi

# Step 7: Save PM2 configuration
pm2 save

echo ""
echo "=========================================="
echo "🎉 Complete Setup Successful!"
echo "=========================================="
echo "📊 Server Status:"
echo "  - URL: $JOT_URL"
echo "  - Data: $JOT_DATA_DIR"
echo "  - Process: PM2 managed"
echo ""
echo "🔑 API Credentials:"
echo "  - API Key: ${API_KEY}"
echo "  - Key ID: ${KEY_ID}"
echo "  - Label: ${API_KEY_LABEL}"
echo "  - Owner Password: ${JOT_PASSWORD}"
echo ""
echo "🛠️  Management Commands:"
echo "  - Check status: pm2 status jot"
echo "  - View logs: pm2 logs jot"
echo "  - Restart: pm2 restart jot"
echo "  - Stop: pm2 stop jot"
echo ""
echo "📚 Usage Examples:"
echo "  - List documents: jot local list"
echo "  - Create document: jot local create \"My Plan\""
echo "  - Read with comments: jot local read <id>"
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT: Save your API key and password securely!"
echo "   Add them to your environment or password manager."