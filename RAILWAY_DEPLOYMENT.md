# Railway Deployment Guide for BlogBowl

## Required Environment Variables

Before deploying to Railway, you MUST configure the following environment variables in your Railway service settings:

### Required Build-Time Variables
These are needed during the Docker build process:

1. **TIPTAP_PRO_TOKEN** (Required for build)
   - Value: `RkFbeGPCsTrRwVQEZpPqg6NzwQDwkEJwCfg1oZnOfvxiARNnceczoCBF77ciAX3C`
   - Purpose: Authenticates with TipTap Pro registry to download editor packages
   - ⚠️ **CRITICAL**: This must be set BEFORE deploying or the build will fail with 403 errors

### Required Runtime Variables

2. **SECRET_KEY_BASE** or **RAILS_MASTER_KEY**
   - Value: Get from your local `config/master.key` file
   - Purpose: Rails encryption key for sessions and credentials

3. **DATABASE_URL**
   - Value: `${{Postgres.DATABASE_URL}}`
   - Purpose: PostgreSQL connection string
   - Note: Use Railway's variable reference syntax to link to your Postgres service

4. **REDIS_URL** (if using Sidekiq)
   - Value: `${{Redis.REDIS_URL}}`
   - Purpose: Redis connection for background jobs

5. **RAILS_ENV**
   - Value: `production`
   - Purpose: Sets Rails environment mode

6. **FRONTEND_URL** (Optional but recommended)
   - Value: Your Railway domain (e.g., `https://your-app.railway.app`)
   - Purpose: Used for mailer URL generation and asset host

## Step-by-Step Deployment

### 1. Create Railway Project
```bash
# From your project directory
railway init
```

### 2. Add Database Services
```bash
railway add
# Select: PostgreSQL
# Select: Redis (if using Sidekiq)
```

### 3. Configure Environment Variables

Go to your service **Variables** section and add:

#### Using Raw Editor (Recommended)
Click "RAW Editor" and paste:

```env
TIPTAP_PRO_TOKEN=RkFbeGPCsTrRwVQEZpPqg6NzwQDwkEJwCfg1oZnOfvxiARNnceczoCBF77ciAX3C
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key_here
DATABASE_URL=${{Postgres.DATABASE_URL}}
REDIS_URL=${{Redis.REDIS_URL}}
```

⚠️ **Replace `your_secret_key_here`** with the actual key from `config/master.key`

### 4. Configure Start Command

In your service **Settings** → **Deploy** section:

**Custom Start Command:**
```bash
bin/rails db:prepare && bin/rails server -b ::
```

This will:
- Run database migrations
- Start the Rails server listening on all interfaces

### 5. Deploy

Option A - Deploy from GitHub:
1. Push code to GitHub repository
2. Connect repository in Railway dashboard
3. Click **Deploy**

Option B - Deploy via CLI:
```bash
railway up
```

### 6. Generate Public Domain

After deployment completes:
1. Go to service **Settings** → **Networking**
2. Click **Generate Domain**
3. Your app will be available at the generated Railway URL

### 7. Update FRONTEND_URL (If Generated Domain)

After getting your Railway domain:
1. Go back to **Variables**
2. Update or add: `FRONTEND_URL=https://your-generated-domain.railway.app`
3. Click **Deploy** to apply changes

## Troubleshooting

### Build fails with "403 error from registry.tiptap.dev"
- **Cause**: `TIPTAP_PRO_TOKEN` not set as environment variable
- **Solution**: Add the token to service variables (see step 3 above)

### "Could not find gem 'core'"
- **Cause**: Git submodules not included
- **Solution**: This repository has submodules flattened - ensure you're using the latest commit

### Database connection errors
- **Cause**: `DATABASE_URL` not configured correctly
- **Solution**: Use Railway reference syntax: `${{Postgres.DATABASE_URL}}`

### Assets not loading
- **Cause**: `FRONTEND_URL` not set
- **Solution**: Add your Railway domain as `FRONTEND_URL` variable

### "frozen mode" bundler errors
- **Cause**: Gemfile.lock mismatch
- **Solution**: The Dockerfile disables frozen mode automatically

## Service Architecture

Your Railway project should have these services:

1. **blogbowl-app** (Main service)
   - Runs the Rails web server
   - Requires: TIPTAP_PRO_TOKEN, SECRET_KEY_BASE, DATABASE_URL, REDIS_URL

2. **Postgres** (Database)
   - Automatically provides DATABASE_URL

3. **Redis** (Cache/Queue)
   - Automatically provides REDIS_URL
   - Required if using Sidekiq

4. **Worker Service** (Optional - for Sidekiq)
   - Custom start command: `bundle exec sidekiq`
   - Uses same environment variables as main app

## RTL Support

This deployment includes RTL (Right-to-Left) support for Arabic content. To enable:

1. After deploying, access your Railway app
2. Log in to admin dashboard
3. Go to Settings → Workspace Settings
4. Set **HTML Language** to `ar` (Arabic)
5. All public blog pages will render in RTL

## Important Notes

- Railway automatically detects the Dockerfile and uses it for builds
- The build process takes 5-10 minutes due to asset compilation
- All environment variables are available during build time (via ARG) and runtime (via ENV)
- Railway provides automatic HTTPS for all generated domains
- Logs are available in the Railway dashboard under "View Logs"

## Support

For Railway-specific issues:
- Railway Docs: https://docs.railway.com
- Railway Discord: https://discord.gg/railway

For BlogBowl issues:
- Check logs in Railway dashboard
- Verify all environment variables are set correctly
- Ensure database migrations ran successfully
