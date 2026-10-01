#!/bin/bash
# ============================================================================
# Quick Start Script for yt-dlp-bot
# Run this to start all services locally for testing
# ============================================================================

set -e

echo "=========================================="
echo "  yt-dlp-bot Quick Start"
echo "=========================================="
echo ""

# Check if config.yml exists
if [ ! -f "app_bot/config.yml" ]; then
    echo "❌ ERROR: app_bot/config.yml not found!"
    echo "   Copy from app_bot/config-example.yml and configure it first."
    echo ""
    echo "   Required values:"
    echo "   - telegram.api_id (from https://my.telegram.org/apps)"
    echo "   - telegram.api_hash (from https://my.telegram.org/apps)"
    echo "   - telegram.token (from @BotFather)"
    echo "   - telegram.allowed_users[0].id (your Telegram user ID)"
    exit 1
fi

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ ERROR: Docker is not running!"
    echo "   Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ ERROR: docker-compose not found!"
    echo "   Try: pip install docker-compose or use docker compose"
    exit 1
fi

echo "✅ Configuration check passed!"
echo ""

# Create downloads directory if it doesn't exist
mkdir -p downloads
echo "📁 Created downloads directory"

# Build base image first
echo "🔨 Building base image..."
docker compose -f docker-compose.render.yml build base-image

# Start all services
echo "🚀 Starting all services..."
echo ""
echo "Services starting:"
echo "  🗃️  PostgreSQL (port 5432)"
echo "  🔴  Redis (port 6379)"
echo "  🐇  RabbitMQ (port 5672, management: 15672)"
echo "  🌐  API (port 1984)"
echo "  🤖  Telegram Bot"
echo "  ⚙️   Worker"
echo ""

docker compose -f docker-compose.render.yml up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service status
echo ""
echo "📊 Service Status:"
docker compose -f docker-compose.render.yml ps

echo ""
echo "=========================================="
echo "  ✅ Services Started!"
echo "=========================================="
echo ""
echo "🔗 Access Points:"
echo "  API:        http://localhost:1984"
echo "  API Docs:   http://localhost:1984/docs"
echo "  RabbitMQ:   http://localhost:15672 (guest/guest)"
echo ""
echo "📝 Test Commands:"
echo "  curl http://localhost:1984/status"
echo "  curl http://localhost:1984/v1/yt-dlp"
echo ""
echo "💬 Telegram Bot:"
echo "  Open Telegram and send a YouTube URL to your bot"
echo ""
echo "📁 Downloads:"
echo "  Files are saved to: ./downloads/"
echo ""
echo "📋 To view logs:"
echo "  docker compose -f docker-compose.render.yml logs -f"
echo ""
echo "⏹️  To stop all services:"
echo "  docker compose -f docker-compose.render.yml down"
echo ""
