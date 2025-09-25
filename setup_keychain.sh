#!/bin/bash

# Keychain Setup Script for OcrToNotion
# This script helps set up the required API credentials in the iOS Keychain
# Run this script on macOS with the iOS Simulator open, or adapt for your credential management

echo "🔑 OcrToNotion Keychain Setup"
echo "================================"
echo ""

# Function to add keychain item (for macOS/Simulator testing)
add_keychain_item() {
    local key="$1"
    local value="$2"
    local description="$3"
    
    echo "Adding $description..."
    # Note: This is for macOS Keychain. On iOS device, you'd need to implement this in the app
    security add-generic-password -a "$key" -s "OcrToNotion" -w "$value" -U
}

echo "Please enter your API credentials:"
echo ""

echo "📝 GPT Configuration:"
read -p "GPT API Key: " gpt_api_key
read -p "GPT Endpoint (e.g., https://api.openai.com/v1/chat/completions): " gpt_endpoint
read -p "GPT Model (e.g., gpt-4o-mini): " gpt_model

echo ""
echo "📋 Notion Configuration:"
read -p "Notion Token: " notion_token
read -p "Notion Database ID: " notion_data_source_id
read -p "Notion Pages Endpoint (default: https://api.notion.com/v1/pages): " notion_pages_endpoint
read -p "Notion API Version (default: 2022-06-28): " notion_api_version

# Set defaults if empty
notion_pages_endpoint=${notion_pages_endpoint:-"https://api.notion.com/v1/pages"}
notion_api_version=${notion_api_version:-"2022-06-28"}

echo ""
echo "Setting up Keychain entries..."

# Add items to keychain
add_keychain_item "gpt_api_key" "$gpt_api_key" "GPT API Key"
add_keychain_item "gpt_endpoint" "$gpt_endpoint" "GPT Endpoint"
add_keychain_item "gpt_model" "$gpt_model" "GPT Model"
add_keychain_item "notion_token" "$notion_token" "Notion Token"
add_keychain_item "notion_data_source_id" "$notion_data_source_id" "Notion Database ID"
add_keychain_item "notion_pages_endpoint" "$notion_pages_endpoint" "Notion Pages Endpoint"
add_keychain_item "notion_api_version" "$notion_api_version" "Notion API Version"

echo ""
echo "✅ Keychain setup complete!"
echo ""
echo "📱 Next steps:"
echo "1. Build and run the OcrToNotion app on your iOS device/simulator"
echo "2. Open Shortcuts app and search for 'OCR 截图并同步到 Notion'"
echo "3. Create your automation workflow!"
echo ""
echo "Note: On real iOS devices, you'll need to implement credential entry within the app."