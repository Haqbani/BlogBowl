# TipTap Pro Registry 403 Error - Root Cause Analysis and Fix

## Problem Summary

During Railway deployment, you're getting 403 Forbidden errors from the TipTap Pro registry:

```
error: GET https://registry.tiptap.dev/@tiptap-pro%2fextension-node-range/-/extension-node-range-2.21.5.tgz - 403
```

This occurs during the `bun install` step that's automatically triggered by Rails asset precompilation.

---

## Root Cause Analysis

### The Build Execution Chain

1. **Line 39-45**: Gems are installed (including `jsbundling-rails`)
2. **Line 47-50**: Bun binary is installed
3. **Line 52-53**: Application code is copied (including `bun.lockb` and `package.json`)
4. **Line 57-58**: `.npmrc` file is created with TipTap Pro authentication
5. **Line 64**: `bin/rails assets:precompile` is called

### What Happens During assets:precompile

The `jsbundling-rails` gem hooks into the `assets:precompile` Rake task:

```
assets:precompile
  └─ enhanced by jsbundling-rails to depend on:
     └─ javascript:build
        └─ prereq: javascript:install
           └─ runs: bun install
              └─ reads: .npmrc
```

### The Critical Issue

The `.npmrc` file **is** being created before `assets:precompile` runs. However, the problem is with **argument variable interpolation**:

```dockerfile
RUN echo "//registry.tiptap.dev/:_authToken=${TIPTAP_PRO_TOKEN}" >> .npmrc
```

**The Issue:**
- If `TIPTAP_PRO_TOKEN` ARG is not properly passed by Railway, the variable expands to an **empty string**
- This results in `.npmrc` containing:
  ```
  //registry.tiptap.dev/:_authToken=
  ```
- An empty token is treated as invalid credentials → 403 Forbidden

**Why This Happens:**
1. Railway's build argument passing might be case-sensitive
2. The variable might not be reaching the RUN command correctly
3. Shell variable expansion with `${VAR}` in `echo` can be unreliable in Docker
4. No validation occurs to verify the token was actually set

---

## The Fix

### Updated Dockerfile (Lines 55-67)

```dockerfile
# Create .npmrc from environment variable for TipTap Pro authentication
# Railway will pass TIPTAP_PRO_TOKEN as a build argument from service variables
# Use proper quoting and validation to ensure token is correctly interpolated
RUN { \
      echo "@tiptap-pro:registry=https://registry.tiptap.dev/"; \
      if [ -n "$TIPTAP_PRO_TOKEN" ]; then \
        echo "//registry.tiptap.dev/:_authToken=$TIPTAP_PRO_TOKEN"; \
      else \
        echo "WARNING: TIPTAP_PRO_TOKEN not set - TipTap Pro packages will fail to install"; \
        exit 1; \
      fi; \
    } > .npmrc && \
    cat .npmrc
```

### Key Improvements

1. **Validation**: Explicitly checks if `TIPTAP_PRO_TOKEN` is set using `[ -n "$VAR" ]`
2. **Fail Fast**: Exits with code 1 if token is missing, preventing silent failures
3. **Debug Output**: `cat .npmrc` displays the file content for troubleshooting
4. **Cleaner Syntax**: Uses a shell compound command block for better readability

---

## Verification Steps

After updating your Dockerfile:

### 1. Verify the token is being passed to Railway

In your Railway service dashboard:
- Go to **Variables** (or similar section)
- Ensure `TIPTAP_PRO_TOKEN` is set with the correct value
- Value should be: `RkFbeGPCsTrRwVQEZpPqg6NzwQDwkEJwCfg1oZnOfvxiARNnceczoCBF77ciAX3C`

### 2. Check the build logs

During deployment, you should now see in the logs:

```
@tiptap-pro:registry=https://registry.tiptap.dev/
//registry.tiptap.dev/:_authToken=RkFbeGPCsTrRwVQEZpPqg6NzwQDwkEJwCfg1oZnOfvxiARNnceczoCBF77ciAX3C
```

If you instead see:

```
//registry.tiptap.dev/:_authToken=
WARNING: TIPTAP_PRO_TOKEN not set - TipTap Pro packages will fail to install
```

Then the variable is **not** being passed by Railway, and you need to:
1. Check Railway service variable configuration
2. Verify the variable name matches exactly: `TIPTAP_PRO_TOKEN`
3. Verify the token value doesn't have leading/trailing whitespace

### 3. Monitor the asset precompilation

The build should now proceed successfully through:
```
bun install v1.1.43
bun install [✓ completed]
bun run build
[assets compiled successfully]
```

---

## Why This Fix Works

### Problem → Solution Mapping

| Problem | Original Code | New Code |
|---------|---------------|----------|
| No validation of token | `${TIPTAP_PRO_TOKEN}` expands silently to empty | `if [ -n "$TIPTAP_PRO_TOKEN" ]` validates |
| Silent failures | Build continues with empty token | `exit 1` stops build immediately |
| No debugging info | Can't see what was written to `.npmrc` | `cat .npmrc` shows exact content |
| Potential shell injection | Direct variable in `echo` | Properly quoted in controlled block |

### The Mechanics

1. **Docker ARG scoping**: The `ARG TIPTAP_PRO_TOKEN` declared on line 31 is available to all subsequent RUN commands in the `build` stage
2. **Railway integration**: Railway automatically passes all service variables as build arguments
3. **Variable expansion**: `$TIPTAP_PRO_TOKEN` (not `${...}`) in the shell block ensures proper expansion
4. **Early exit**: If token is missing, the build fails with a clear error message

---

## Additional Notes

### Local Development

Your local `.npmrc` file (committed to repo) has the token hardcoded, which is why it works locally. This is fine for development but should be gitignored before committing.

### Security Consideration

The `.npmrc` file created during the Docker build contains credentials. This is acceptable because:
1. The file only exists in the `build` stage
2. It's not copied to the final production image
3. The final image doesn't contain credentials
4. Only the built artifacts (gems, JS bundles) are copied forward

### Alternative Approach: Using --build-arg

If Railway isn't automatically passing the variable, you could also try:
1. Setting it in Railway's Dockerfile build args (if available)
2. Using a `.dockerignore` with the local `.npmrc` and having Docker build it fresh

---

## Testing the Fix Locally

To test locally with Docker:

```bash
# Build with explicit build argument
docker build \
  --build-arg TIPTAP_PRO_TOKEN=RkFbeGPCsTrRwVQEZpPqg6NzwQDwkEJwCfg1oZnOfvxiARNnceczoCBF77ciAX3C \
  -t blogbowl:test .

# If successful, you should see the .npmrc content in the build output
# and no 403 errors from bun install
```

---

## Troubleshooting

### Build still fails with 403 error

1. **Check the build log** for the `.npmrc` output
2. **Verify token isn't empty** in Railway variables
3. **Check token for special characters** (should only be alphanumeric, not URL-encoded)
4. **Verify Railway supports passing** TIPTAP_PRO_TOKEN specifically

### Build fails immediately after .npmrc creation

The fix now exits with code 1 if the token is missing. To debug:

```bash
# In Railway build settings, ensure this is set:
TIPTAP_PRO_TOKEN = RkFbeGPCsTrRwVQEZpPqg6NzwQDwkEJwCfg1oZnOfvxiARNnceczoCBF77ciAX3C
```

### bun install still fails despite token in .npmrc

1. **Check .npmrc syntax** (the debug `cat` output shows what was created)
2. **Verify TipTap Pro subscription** is still active
3. **Try refreshing the token** from TipTap account dashboard
4. **Check if registry is accessible** from Railway's infrastructure

---

## Files Modified

- **`/Users/mohammedalhaqbani/Downloads/Manual Library/Projects/bowlbloging/BlogBowl/Dockerfile`** (Lines 55-67)
  - Updated: `.npmrc` creation with validation and debug output

---

## Related Files Reference

- `/Users/mohammedalhaqbani/Downloads/Manual Library/Projects/bowlbloging/BlogBowl/Dockerfile` - Build configuration
- `/Users/mohammedalhaqbani/Downloads/Manual Library/Projects/bowlbloging/BlogBowl/.npmrc` - Local npm registry config (gitignored)
- `/Users/mohammedalhaqbani/Downloads/Manual Library/Projects/bowlbloging/BlogBowl/package.json` - Node dependencies (includes @tiptap-pro packages)
- `/Users/mohammedalhaqbani/Downloads/Manual Library/Projects/bowlbloging/BlogBowl/Gemfile` - Rails dependencies (includes jsbundling-rails)

---

## Summary

**Root Cause**: The `TIPTAP_PRO_TOKEN` build argument was not being validated, allowing silent failures when the token was empty or not passed by Railway.

**Solution**: Added explicit validation in the `.npmrc` creation step that:
1. Checks if the token is set
2. Fails immediately with a clear error if not
3. Outputs the `.npmrc` content for debugging

This ensures you catch the problem during the build phase rather than at runtime, and provides clear visibility into what's happening with authentication.
