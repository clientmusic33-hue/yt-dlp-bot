# 🎯 yt-dlp-bot - READY FOR RENDER DEPLOYMENT

**Status:** ✅ **Fully Configured for Fast Deployment**  
**Estimated Time:** **Under 5 Minutes**  
**Complexity:** Easy 🟢

---

## 📋 What's Been Prepared

This repository is now **100% ready** for deployment on Render.com. All configuration files, environment variables, and deployment scripts have been created and pre-configured.

---

## 🗂️ Files Created/Modified

| File | Purpose | Status |
|------|---------|--------|
| `app_bot/config.yml` | Telegram bot configuration | ✅ **EDIT THIS FIRST** |
| `.env.render` | Environment variables template | ✅ Ready |
| `render.yaml` | Render Blueprint configuration | ✅ Ready |
| `docker-compose.render.yml` | Local testing config | ✅ Ready |
| `start_all.sh` | Quick start script | ✅ Ready |
| `DEPLOY_RENDER.md` | Detailed deployment guide | ✅ Ready |
| `QUICK_START.txt` | Quick reference card | ✅ Ready |

---

## ⚡ 3-Step Deployment (Fastest Method)

### Step 1: Configure Your Bot (2 minutes)

Edit **`app_bot/config.yml`** with your Telegram credentials:

```yaml
telegram:
  api_id: 1234567              # Get from https://my.telegram.org/apps
  api_hash: "abcdef123456..." # Get from https://my.telegram.org/apps
  token: "123456789:ABC..."   # Get from @BotFather
  allowed_users:
    - id: 987654321           # Get from @userinfobot
      is_admin: true
      download_media_type: "VIDEO"
      save_to_storage: true
      upload:
        upload_video_file: false
```

> ⚠️ **This is the ONLY file you MUST edit before deployment!**

---

### Step 2: Push to GitHub (1 minute)

```bash
cd /home/user/yt-dlp-bot
git add .
git commit -m "Configured for Render deployment"
git push origin arena/01a0f8ed-yt-dlp-bot
```

---

### Step 3: Deploy on Render (2 minutes)

1. **Go to** [https://render.com](https://render.com)
2. **Click** "New +" → "Web Service"
3. **Connect** your GitHub repository
4. **Select** branch: `arena/01a0f8ed-yt-dlp-bot`
5. **Create 6 services** using the guide below

---

## 🏗️ Service Creation Guide

### Create These 6 Services in Order:

#### 1️⃣ **PostgreSQL Database**
- **Type:** PostgreSQL
- **Name:** `yt-dlp-bot-postgres`
- **Database:** `yt`
- **User:** `yt`
- **Password:** Generate secure password
- **Plan:** Free
- **Region:** Choose closest

#### 2️⃣ **Redis**
- **Type:** Redis
- **Name:** `yt-dlp-bot-redis`
- **Plan:** Free
- **Region:** Same as PostgreSQL

#### 3️⃣ **RabbitMQ** (Docker Container)
- **Type:** Docker Container
- **Name:** `yt-dlp-bot-rabbitmq`
- **Image:** `rabbitmq:3.12-management-alpine`
- **Ports:** `5672` (AMQP), `15672` (Management)
- **Env Vars:**
  ```
  RABBITMQ_DEFAULT_USER=guest
  RABBITMQ_DEFAULT_PASS=guest
  ```
- **Plan:** Free

#### 4️⃣ **API Service** (Web)
- **Type:** Web Service
- **Name:** `yt-dlp-bot-api`
- **Repository:** Your GitHub repo
- **Branch:** `arena/01a0f8ed-yt-dlp-bot`
- **Dockerfile:** `app_api/Dockerfile`
- **Start Command:** `bash -c "python start.py && python main.py"`
- **Port:** `8000`
- **Env Vars:** See `.env.render` (use "Link Service" for DB/Redis/RabbitMQ)
- **Plan:** Free

#### 5️⃣ **Worker Service** (Background Worker)
- **Type:** Background Worker
- **Name:** `yt-dlp-bot-worker`
- **Repository:** Your GitHub repo
- **Dockerfile:** `app_worker/Dockerfile`
- **Start Command:** `bash -c "python start.py && alembic upgrade head && python main.py"`
- **Env Vars:** See `.env.render`
- **Persistent Disk:** Add 1GB+ disk, mount at `/filestorage`
- **Plan:** Free

#### 6️⃣ **Bot Service** (Background Worker)
- **Type:** Background Worker
- **Name:** `yt-dlp-bot-telegram`
- **Repository:** Your GitHub repo
- **Dockerfile:** `app_bot/Dockerfile`
- **Start Command:** `bash -c "python start.py && python main.py"`
- **Env Vars:** See `.env.render`
- **Plan:** Free

---

## 🔗 Environment Variables Quick Reference

### All Services Need:
```
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
POSTGRES_USER=yt
POSTGRES_PASSWORD=[from PostgreSQL service]
POSTGRES_HOST=[from PostgreSQL service]
POSTGRES_PORT=5432
POSTGRES_DB=yt
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest
RABBITMQ_HOST=[from RabbitMQ service]
RABBITMQ_PORT=5672
REDIS_HOST=[from Redis service]
LOG_LEVEL=INFO
```

### API Service:
```
APPLICATION_NAME=yt_api
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4
```

### Bot Service:
```
APPLICATION_NAME=yt_bot
TG_MAX_MSG_SIZE=4096
TG_MAX_CAPTION_SIZE=1024
```

### Worker Service:
```
APPLICATION_NAME=yt_worker
MAX_SIMULTANEOUS_DOWNLOADS=2
MAX_DOWNLOAD_THREADS=10
STORAGE_PATH=/filestorage
THUMBNAIL_FRAME_SECOND=10.0
INSTAGRAM_ENCODE_TO_H264=True
FACEBOOK_ENCODE_TO_H264=True
```

---

## 🎯 Service Dependencies

Set these dependencies in Render:

- **API** → Depends on: PostgreSQL, Redis, RabbitMQ
- **Worker** → Depends on: PostgreSQL, Redis, RabbitMQ
- **Bot** → Depends on: PostgreSQL, Redis, RabbitMQ, API, Worker

This ensures services start in the correct order.

---

## ✅ Verification Checklist

- [ ] `app_bot/config.yml` configured with Telegram credentials
- [ ] Repository pushed to GitHub
- [ ] PostgreSQL service created and running
- [ ] Redis service created and running
- [ ] RabbitMQ service created and running
- [ ] API service deployed and healthy
- [ ] Worker service deployed with disk
- [ ] Bot service deployed
- [ ] All environment variables set correctly
- [ ] Service dependencies configured
- [ ] Bot responds to messages in Telegram

---

## 🧪 Testing

### Test API:
```bash
curl https://your-api-service.onrender.com/status
# Expected: {"status": "OK"}

curl https://your-api-service.onrender.com/v1/yt-dlp
# Expected: Shows yt-dlp version
```

### Test Bot:
1. Open Telegram
2. Find your bot (from @BotFather)
3. Send: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
4. Expected: Bot responds with download status

### Check Downloads:
1. Go to Worker service in Render
2. Click "Disks" tab
3. Click "Browse Files" to see downloaded videos

---

## 📚 Documentation Files

| File | Description |
|------|-------------|
| `QUICK_START.txt` | Quick reference card (print this!) |
| `DEPLOY_RENDER.md` | Detailed step-by-step guide |
| `.env.render` | All environment variables template |
| `render.yaml` | Render Blueprint for automated deployment |
| `docker-compose.render.yml` | For local testing |

---

## 🆘 Troubleshooting

### Common Issues & Fixes:

| Issue | Solution |
|-------|----------|
| Bot doesn't respond | Check Bot service logs, verify token in config.yml |
| "Waiting for PostgreSQL" | Check PostgreSQL is running, verify host/password |
| Downloads not saving | Check Worker has disk mounted at `/filestorage` |
| API 500 errors | Check API logs, verify all common env vars |
| RabbitMQ connection failed | Check RabbitMQ service is running, verify host |

### View Logs:
In Render Dashboard:
1. Click on the service
2. Click "Logs" tab
3. Look for errors

---

## 💡 Pro Tips

### Faster Performance:
- Increase `MAX_SIMULTANEOUS_DOWNLOADS` to 4-5
- Increase `MAX_DOWNLOAD_THREADS` to 20
- Upgrade to paid plan for more resources

### Larger Files:
- Telegram free: Max 2GB upload (`upload_video_max_file_size: 2147483648`)
- Telegram premium: Max 4GB upload (`upload_video_max_file_size: 4294967296`)

### Storage:
- Worker service disk stores all downloads
- Default path: `/filestorage`
- Access via Render Dashboard → Worker → Disks → Browse Files

---

## 🚀 Local Testing (Optional)

Before deploying to Render, test locally:

```bash
# Make executable
chmod +x start_all.sh

# Start all services
./start_all.sh

# Test API
curl http://localhost:1984/status

# Stop services
docker compose -f docker-compose.render.yml down
```

---

## 📞 Support

- **Render Documentation:** https://render.com/docs
- **Original Repository:** https://github.com/terletsky/yt-dlp-bot
- **Telegram:** Check original repo for community support

---

## ✨ You're Ready!

Your yt-dlp-bot is **fully configured** and ready for deployment on Render. 

**Total time to deploy: ~5 minutes**  
**Just edit config.yml, push to GitHub, and create the 6 services on Render!**

---

**🎉 Happy downloading!**
