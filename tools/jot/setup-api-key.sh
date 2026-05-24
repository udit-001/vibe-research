#!/bin/bash
# Automated Jot API Key Setup Script
# Creates owner account and generates API key without user interaction

set -e

# Configuration - adjust these values
JOT_URL="http://localhost:3210"
JOT_PASSWORD="your-secure-password-here"
API_KEY_LABEL="automated-setup"
COOKIES_FILE="/tmp/jot-cookies.txt"

echo "🚀 Setting up Jot API key automatically..."

# Step 1: Set up owner account and get device token
echo "📝 Creating owner account..."
SETUP_RESPONSE=$(curl -s -X POST "${JOT_URL}/api/auth/setup" \
  -H "Content-Type: application/json" \
  -d "{\"password\":\"${JOT_PASSWORD}\",\"confirmPassword\":\"${JOT_PASSWORD}\"}")

DEVICE_TOKEN=$(echo "$SETUP_RESPONSE" | jq -r '.token')

if [ "$DEVICE_TOKEN" == "null" ] || [ -z "$DEVICE_TOKEN" ]; then
  echo "❌ Failed to get device token. Response: $SETUP_RESPONSE"
  exit 1
fi

echo "✅ Owner account created, device token received"

# Step 2: Exchange device token for session cookie
echo "🔐 Exchanging device token for session..."
curl -s -c "$COOKIES_FILE" -X POST "${JOT_URL}/api/auth/token" \
  -H "Content-Type: application/json" \
  -d "{\"token\":\"${DEVICE_TOKEN}\"}" > /dev/null

echo "✅ Session cookie established"

# Step 3: Create API key
echo "🔑 Creating API key..."
KEY_RESPONSE=$(curl -s -b "$COOKIES_FILE" -X POST "${JOT_URL}/api/keys" \
  -H "Content-Type: application/json" \
  -d "{\"label\":\"${API_KEY_LABEL}\"}")

API_KEY=$(echo "$KEY_RESPONSE" | jq -r '.key')
KEY_ID=$(echo "$KEY_RESPONSE" | jq -r '.id')

if [ "$API_KEY" == "null" ] || [ -z "$API_KEY" ]; then
  echo "❌ Failed to create API key. Response: $KEY_RESPONSE"
  exit 1
fi

# Clean up cookies file
rm -f "$COOKIES_FILE"

echo "✅ API key created successfully!"
echo ""
echo "=========================================="
echo "🎉 Setup Complete!"
echo "=========================================="
echo "API Key: ${API_KEY}"
echo "Key ID: ${KEY_ID}"
echo "Label: ${API_KEY_LABEL}"
echo ""
echo "Use this API key to register the CLI:"
echo "jot register local ${JOT_URL} ${API_KEY}"
echo ""
echo "Save the API key securely - it won't be shown again!"
echo "=========================================="