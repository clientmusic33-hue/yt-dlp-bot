# 🚀 Fast Deployment Guide for yt-dlp-bot on Render

This guide will get your yt-dlp-bot deployed on **Render.com** in **under 5 minutes**!

---

## ✅ Prerequisites

1. **A Render account** - [Sign up here](https://render.com/) (Free tier available)
2. **A GitHub account** - To connect your repository
3. **Telegram Bot Token** - Get from [@BotFather](https://t.me/BotFather)
4. **Telegram API Keys** - Get from [my.telegram.org/apps](https://my.telegram.org/apps)
5. **Your Telegram User ID** - Get from [@userinfobot](https://t.me/userinfobot)

---

## 📋 Step 1: Prepare Your Repository

### 1.1 Fork & Clone (if not already done)
```bash
# Fork the repository on GitHub
# Then clone it
git clone https://github.com/your-username/yt-dlp-bot.git
cd yt-dlp-bot
```

### 1.2 Configure Telegram Bot
Edit **`app_bot/config.yml`** with your credentials:

```yaml
telegram:
  api_id: YOUR_API_ID          # From my.telegram.org/apps
  api_hash: "YOUR_API_HASH"   # From my.telegram.org/apps
  token: "YOUR_BOT_TOKEN"     # From @BotFather
  allowed_users:
    - id: YOUR_USER_ID        # From @userinfobot
      is_admin: true
      download_media_type: "VIDEO"  # or AUDIO, AUDIO_VIDEO
      save_to_storage: true
      upload:
        upload_video_file: false  # Set to true to auto-upload to Telegram
```

> ⚠️ **IMPORTANT**: Replace all `CHANGE_ME` placeholders with your actual values!

---

## 🏗️ Step 2: Deploy on Render

### Option A: **One-Click Deploy (Recommended)** ✨

1. Go to: [https://render.com](https://render.com)
2. Click **"New +"** → **"Blueprint"**
3. Click **"Start with a blank blueprint"**
4. Name it: `yt-dlp-bot`
5. Click **"Define a service"**

### Option B: **Manual Service Setup**

#### Service 1: PostgreSQL Database
- **Type**: PostgreSQL
- **Name**: `yt-dlp-bot-postgres`
- **Database Name**: `yt`
- **User**: `yt`
- **Password**: Generate a strong password
- **Plan**: Free
- **Region**: Choose closest to you

#### Service 2: Redis
- **Type**: Redis
- **Name**: `yt-dlp-bot-redis`
- **Plan**: Free
- **Region**: Same as PostgreSQL

#### Service 3: RabbitMQ (Docker)
- **Type**: Docker Container
- **Name**: `yt-dlp-bot-rabbitmq`
- **Image**: `rabbitmq:3.12-management-alpine`
- **Ports**: `5672` (AMQP), `15672` (Management)
- **Environment Variables**:
  - `RABBITMQ_DEFAULT_USER=guest`
  - `RABBITMQ_DEFAULT_PASS=guest`
- **Plan**: Free

#### Service 4: API (Web Service)
- **Type**: Web Service
- **Name**: `yt-dlp-bot-api`
- **Repository**: Connect your GitHub repo
- **Branch**: `main` or `arena/01a0f8ed-yt-dlp-bot`
- **Dockerfile**: `app_api/Dockerfile`
- **Build Command**: `docker build -t yt-api .`
- **Start Command**: `bash -c "python start.py && python main.py"`
- **Port**: `8000`
- **Environment Variables** (see below)
- **Plan**: Free

#### Service 5: Telegram Bot (Worker)
- **Type**: Background Worker
- **Name**: `yt-dlp-bot-telegram`
- **Repository**: Your GitHub repo
- **Dockerfile**: `app_bot/Dockerfile`
- **Start Command**: `bash -c "python start.py && python main.py"`
- **Environment Variables** (see below)
- **Plan**: Free

#### Service 6: Download Worker (Worker)
- **Type**: Background Worker
- **Name**: `yt-dlp-bot-worker`
- **Repository**: Your GitHub repo
- **Dockerfile**: `app_worker/Dockerfile`
- **Start Command**: `bash -c "python start.py && alembic upgrade head && python main.py"`
- **Environment Variables** (see below)
- **Disk**: Add a **Persistent Disk** (1GB+ recommended)
  - Mount Path: `/filestorage`
- **Plan**: Free

---

## 🔧 Step 3: Environment Variables

### For ALL Services (Common)
```
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
PYTHONASYNCIODEBUG=0
POSTGRES_USER=yt
POSTGRES_PASSWORD=your_postgres_password_from_render
POSTGRES_HOST=your_postgres_hostname_from_render
POSTGRES_PORT=5432
POSTGRES_DB=yt
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest
RABBITMQ_HOST=your_rabbitmq_hostname_from_render
RABBITMQ_PORT=5672
REDIS_HOST=your_redis_hostname_from_render
TMP_DOWNLOAD_ROOT_PATH=/tmp/download_tmpfs
TMP_DOWNLOAD_DIR=downloading
TMP_DOWNLOADED_DIR=downloaded
LOG_LEVEL=INFO
```

### For API Service Only
```
APPLICATION_NAME=yt_api
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4
```

### For Bot Service Only
```
APPLICATION_NAME=yt_bot
TG_MAX_MSG_SIZE=4096
TG_MAX_CAPTION_SIZE=1024
```

### For Worker Service Only
```
APPLICATION_NAME=yt_worker
MAX_SIMULTANEOUS_DOWNLOADS=2
MAX_DOWNLOAD_THREADS=10
STORAGE_PATH=/filestorage
THUMBNAIL_FRAME_SECOND=10.0
INSTAGRAM_ENCODE_TO_H264=True
FACEBOOK_ENCODE_TO_H264=True
```

> 💡 **Tip**: Use Render's **"Link Service"** feature to automatically populate database/Redis hostnames and passwords!

---

## 📡 Step 4: Service Dependencies

Make sure services start in this order:
1. **PostgreSQL** (must start first)
2. **Redis**
3. **RabbitMQ**
4. **API** (depends on 1,2,3)
5. **Worker** (depends on 1,2,3)
6. **Bot** (depends on 1,2,3,4,5)

In Render, set dependencies:
- API → Depends on: PostgreSQL, Redis, RabbitMQ
- Worker → Depends on: PostgreSQL, Redis, RabbitMQ
- Bot → Depends on: PostgreSQL, Redis, RabbitMQ, API, Worker

---

## ✅ Step 5: Deploy & Test

1. Click **"Apply"** or **"Create"** for all services
2. Wait for all services to build and start (5-10 minutes)
3. Check the **Logs** for each service
4. **Test your bot**:
   - Open Telegram and find your bot
   - Send a YouTube URL (e.g., `https://www.youtube.com/watch?v=dQw4w9WgXcQ`)
   - The bot should respond with download status

---

## 🎯 Quick Verification

| Service | Health Check | Expected Output |
|---------|--------------|-----------------|
| API | `GET /status` | `{"status": "OK"}` |
| API | `GET /v1/yt-dlp` | Shows yt-dlp version |
| Bot | Telegram message | Startup message: `✨ BOT_NAME started, paste a video URL(s) to start download` |

---

## 💾 Storage Configuration

**Important**: Downloaded files are saved to `/filestorage`

To access your downloads:
1. The Worker service has a **Persistent Disk** mounted at `/filestorage`
2. In Render, go to your Worker service → **"Disks"** tab
3. Click **"Browse Files"** to view/download files

---

## ⚡ Performance Tips

### For Faster Downloads
- Increase `MAX_SIMULTANEOUS_DOWNLOADS` to 4-5 (Worker env)
- Increase `MAX_DOWNLOAD_THREADS` to 20 (Worker env)
- Upgrade to a paid plan for more CPU/memory

### For Larger Files
- Telegram free users: Max 2GB upload
- Telegram premium: Max 4GB upload
- Set `upload_video_max_file_size` in `config.yml` accordingly

---

## 🆘 Troubleshooting

### "Waiting for PostgreSQL/RabbitMQ to be reachable"
- **Fix**: Check if PostgreSQL and RabbitMQ services are running
- Check service dependencies are set correctly
- Verify hostnames match exactly

### Bot doesn't respond
- **Fix**: Check Bot service logs
- Verify `token` in `config.yml` is correct
- Make sure bot is added to your chat

### Downloads fail
- **Fix**: Check Worker service logs
- Verify `STORAGE_PATH` exists and is writable
- Check if the URL is valid and accessible

### API returns 500 errors
- **Fix**: Check API service logs
- Verify database connection
- Check all common environment variables

---

## 📞 Need Help?

- **Render Docs**: [https://render.com/docs](https://render.com/docs)
- **Original Repo**: [https://github.com/terletsky/yt-dlp-bot](https://github.com/terletsky/yt-dlp-bot)
- **Telegram Support**: Join the discussion in the original repo

---

## 🎉 You're Done!

Your yt-dlp-bot should now be running on Render! 🎉

- **API**: `https://your-api-service.onrender.com`
- **Bot**: Talk to your bot in Telegram
- **Downloads**: Check the Worker service's disk

Enjoy downloading videos! 🚀
