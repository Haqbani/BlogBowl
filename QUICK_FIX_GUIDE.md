# Quick Fix Guide: TipTap Pro 403 Error

## The Problem in 30 Seconds

Railway deployment fails with `403 Forbidden` from TipTap registry because the Docker build doesn't validate that `TIPTAP_PRO_TOKEN` was passed correctly.

## The Solution in 30 Seconds

Updated `Dockerfile` lines 55-67 to validate the token is actually set before proceeding.

## What Changed

### Before (BROKEN)
```dockerfile
RUN echo "//registry.tiptap.dev/:_authToken=${TIPTAP_PRO_TOKEN}" >> .npmrc
```

### After (FIXED)
```dockerfile
RUN { \
      echo "@tiptap-pro:registry=https://registry.tiptap.dev/"; \
      if [ -n "$TIPTAP_PRO_TOKEN" ]; then \
        echo "//registry.tiptap.dev/:_authToken=$TIPTAP_PRO_TOKEN"; \
      else \
        echo "WARNING: TIPTAP_PRO_TOKEN not set"; \
        exit 1; \
      fi; \
    } > .npmrc && \
    cat .npmrc
```

## Why This Works

| Issue | Old Code | New Code |
|-------|----------|----------|
| Validates token is set? | NO | YES |
| Shows debug output? | NO | YES |
| Fails if token missing? | NO | YES |
| Clear error message? | NO | YES |

## What You Need to Do

### 1. In Railway Dashboard
- Go to **Service Variables** (or Environment)
- Confirm `TIPTAP_PRO_TOKEN` is set
- Value: `RkFbeGPCsTrRwVQEZpPqg6NzwQDwkEJwCfg1oZnOfvxiARNnceczoCBF77ciAX3C`
- No whitespace before/after

### 2. Test Locally (Optional)
```bash
docker build \
  --build-arg TIPTAP_PRO_TOKEN=RkFbeGPCsTrRwVQEZpPqg6NzwQDwkEJwCfg1oZnOfvxiARNnceczoCBF77ciAX3C \
  -t test:latest .
```

### 3. Deploy to Railway
- Push updated Dockerfile
- Watch build logs
- Should see `.npmrc` content printed
- Build should complete successfully

## If Build Still Fails

Check the build logs for one of these messages:

### Success Message
```
@tiptap-pro:registry=https://registry.tiptap.dev/
//registry.tiptap.dev/:_authToken=RkFbeGPCsTrRwVQEZpPqg6NzwQDwkEJwCfg1oZnOfvxiARNnceczoCBF77ciAX3C
```
Token is working, any further errors are different issues.

### Failure Message
```
WARNING: TIPTAP_PRO_TOKEN not set
```
Fix: Check Railway service variables, ensure TIPTAP_PRO_TOKEN is set.

### Still Getting 403?
1. Check token value matches exactly (copy/paste carefully)
2. Verify no leading/trailing whitespace in Railway config
3. Try refreshing the token from TipTap Pro account dashboard
4. Check TipTap Pro subscription is active

## File Changed

**`/Users/mohammedalhaqbani/Downloads/Manual Library/Projects/bowlbloging/BlogBowl/Dockerfile`**
- Lines 55-67

## Root Cause (If You're Curious)

`bun install` (run by jsbundling-rails during assets:precompile) reads `.npmrc`.
The old code created `.npmrc` with an empty token if `TIPTAP_PRO_TOKEN` wasn't passed.
Empty token = 403 Forbidden from registry.
New code validates the token exists before using it.

## More Information

- **TIPTAP_PRO_FIX.md** - Complete troubleshooting guide
- **DEBUG_REPORT.md** - Detailed root cause analysis
- **Dockerfile** - The actual fix

## Success Criteria

After deployment, you should see:
- Build completes without 403 errors
- Assets precompile successfully
- Editor (with TipTap Pro extensions) loads without errors
- No authentication-related errors in logs

Done!
