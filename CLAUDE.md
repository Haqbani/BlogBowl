# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BlogBowl is a self-hosted blogging platform for blogs, product changelogs, and help centers. It uses a **Rails Engine architecture** where core business logic lives in `/submodules/core` (a local gem), and the host application provides customization and deployment configuration.

**Key Architectural Pattern:**
- **Core Engine** (`submodules/core/`): Contains models, controllers, migrations, and business logic. This is where most application code lives.
- **Host Application** (root): Minimal routes (delegated to engine), customization layer, and deployment configuration.
- **Editor Submodule** (`submodules/editor/`): Separate TipTap-based rich text editor with React components.

All three components (host app + core engine + editor) work together, but the core engine is the primary location for feature development.

## Technology Stack

- **Backend:** Ruby 3.2.2, Rails 8.0.2
- **Database:** PostgreSQL
- **Cache/Jobs:** Redis + Sidekiq
- **Frontend Bundler:** Bun (not npm/yarn)
- **CSS:** Tailwind CSS 4.1.7 (3 separate builds: application, public, editor)
- **JavaScript:** Hotwire (Turbo + Stimulus) + React components for editor
- **Rich Text Editor:** TipTap with Pro extensions
- **Email:** Postmark API (with SMTP fallback)
- **Storage:** S3-compatible (with local fallback)

## Essential Commands

### Initial Setup
```bash
# One-time setup (installs deps, prepares DB, starts server)
bin/setup

# Skip auto-starting the server
bin/setup --skip-server
```

### Development Server
```bash
# Start all development processes (infra, web, sidekiq, js, css)
bin/dev

# Runs via Foreman with Procfile.dev:
# - PostgreSQL + Redis containers (docker-compose.dev.yaml)
# - Rails server (port 3000)
# - Sidekiq worker (1 thread)
# - Bun bundler (watch mode)
# - Tailwind CSS builds (3 concurrent watchers)
```

### Database
```bash
# Create/migrate/seed database
bin/rails db:setup

# Run migrations (includes core engine migrations)
bin/rails db:migrate

# Reset database
bin/rails db:reset

# Prepare database (create if needed, then migrate)
bin/rails db:prepare
```

### Testing
```bash
# Run all tests (host app + core engine)
bin/rails test

# Run only core engine tests
bin/rake test:core_engine

# Run specific test file
bin/rails test test/models/user_test.rb

# Run tests with verbose output
bin/rails test -v
```

The default `bin/rails test` automatically runs both host application tests AND core engine tests (via Rake task enhancement).

### Code Quality
```bash
# Security vulnerability scan
bin/brakeman --no-pager

# Lint Ruby code (Rails Omakase style)
bin/rubocop

# Auto-fix linting issues
bin/rubocop -a
```

### Assets & Building
```bash
# Build JavaScript bundles (3 entrypoints via bun.config.js)
bun run build

# Build all CSS (application + public + editor)
bun run build:css

# Watch mode for CSS
bun run build:css:watch

# Precompile assets for production
bin/rails assets:precompile
```

### Docker
```bash
# Production stack (app, postgres, redis, sidekiq)
docker compose up -d

# Development infrastructure only (postgres + redis)
docker compose -f docker-compose.dev.yaml up

# Test infrastructure
docker compose -f docker-compose.test.yaml up

# View logs
docker compose logs -f blogbowl_app

# Stop all containers
docker compose down
```

## CSS Build System (Important!)

Tailwind CSS has **3 separate builds** with different input/output paths:

1. **Application CSS** (admin/backend UI):
   - Input: `submodules/core/app/assets/stylesheets/core/application.tailwind.css`
   - Output: `app/assets/builds/application.css`

2. **Public CSS** (blog/public-facing pages):
   - Input: `submodules/core/app/assets/stylesheets/core/public/basic.tailwind.css`
   - Output: `app/assets/builds/public/basic.css`

3. **Editor CSS** (TipTap editor):
   - Input: `submodules/core/app/assets/stylesheets/core/editor/editor.tailwind.css`
   - Output: `app/assets/builds/editor/editor.css`

When modifying styles, ensure you're editing the correct source file and running the appropriate build command.

## JavaScript Build System

Bun bundles 3 entrypoints (defined in `bun.config.js`):
- Application JavaScript
- Public JavaScript
- Editor JavaScript

Use `bun run build --watch` during development to auto-rebuild on changes.

## Environment Configuration

Required environment variables (see `.env.example`):

**Database:**
- `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`

**Email (Postmark or SMTP):**
- `POSTMARK_ACCOUNT_TOKEN`, `POSTMARK_X_API_KEY` (for newsletters)
- OR configure SMTP settings

**Storage (Optional - S3):**
- `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`, `S3_ENDPOINT`, `S3_REGION`, `S3_BUCKET`

**Domain Routing:**
- `BASE_DOMAIN` (for subdomain-based workspace routing)

## Working with Submodules

The core business logic is in a git submodule. When making changes:

```bash
# Initialize submodules (after fresh clone)
git submodule update --init --recursive

# Update submodules to latest
git submodule update --remote

# Make changes in submodule
cd submodules/core
# ... make changes ...
git add . && git commit -m "Your changes"
cd ../..

# Commit submodule reference update in host app
git add submodules/core
git commit -m "Update core submodule"
```

**Important:** CI/CD requires `submodules: true` in GitHub Actions checkout steps (already configured in `.github/workflows/ci.yml`).

## Default Admin Credentials

On first setup, database seeds with:
- **Email:** `admin@example.com`
- **Password:** `changeme`

**Change these immediately after first login.**

## Authentication & Authorization

- **Authentication:** BCrypt password hashing via Rails `has_secure_password`
- **Authorization:** CanCanCan gem for role-based access control
- **Sessions:** Database-backed sessions (see `db/migrate/*_create_sessions.core_engine.rb`)

## Multi-Workspace Architecture

Single database, multiple workspaces:
- Workspaces are isolated by `workspace_id` foreign keys
- Each workspace can have custom domains or subdomain routing
- Pages belong to workspaces (blogs, changelogs, help centers)
- Members have workspace-scoped permissions

## Newsletter System

- **Provider:** Postmark API (100 free emails/month)
- **Queue:** Sidekiq for async email sending
- **Tracking:** Webhook support for opens, clicks, bounces, spam reports
- **Subscribers:** Email validation via Truemail gem, double opt-in support

## Testing Strategy

Tests are split between:
1. **Host application tests** (`test/` in root)
2. **Core engine tests** (`submodules/core/test/`)

The custom rake task (`lib/tasks/engine_tests.rake`) loads core engine tests into the host app's test context. Running `bin/rails test` executes both automatically.

## CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/ci.yml`):
1. **Security Scan:** Brakeman vulnerability check
2. **Lint:** RuboCop style enforcement (Rails Omakase preset)
3. **Test:** Full test suite with PostgreSQL + Redis services

**Important:** Tests run on ports 5434 (postgres) and 6381 (redis) to avoid conflicts.

## Routes Architecture

The host application's `config/routes.rb` is intentionally minimal (nearly empty). All routes are defined and mounted by the core engine. This is by design—the engine handles all routing logic.

## Image Processing

Uses `ruby-vips` (libvips wrapper) for image transformations and variants. Requires `libvips` system package to be installed.

## Development Email Preview

In development, emails are opened in the browser via `letter_opener` gem. Check your terminal output for preview URLs after triggering email actions.
