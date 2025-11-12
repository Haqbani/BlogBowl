# Arabic Seed Data Documentation

This document describes the Arabic seed data implementation for BlogBowl.

## Overview

All database seed files and test fixtures have been updated to use Arabic content instead of English. This ensures that new installations and test environments start with Arabic content by default, matching the RTL transformation of the application.

## Files Updated

### 1. Main Seed File
**File:** `db/seeds.rb`

Creates a complete Arabic blog setup with:
- Default admin user (أحمد المدير)
- Workspace with Arabic locale (`ar-SA`)
- Blog page (مدونتي)
- 4 categories (غير مصنف, تكنولوجيا, ثقافة, تطوير شخصي)
- 4 sample posts with rich Arabic content
- Navigation and footer links in Arabic
- All SEO metadata in Arabic

### 2. Test Fixtures
**Location:** `submodules/core/test/fixtures/`

All fixture files updated:
- `users.yml` - Arabic names for users
- `workspaces.yml` - Arabic workspace titles
- `workspace_settings.yml` - Arabic locale (`ar-SA`)
- `pages.yml` - Arabic page names (مدونتي)
- `page_settings.yml` - Arabic SEO and settings
- `categories.yml` - Arabic category names
- `posts.yml` - Arabic post titles and content
- `authors.yml` - Arabic author names and descriptions
- `links.yml` - Arabic link titles (الرئيسية, عام)
- `newsletters.yml` - Arabic newsletter names

### 3. Data Migration
**File:** `db/migrate/20251111181735_update_existing_data_to_arabic.rb`

A migration that updates existing English data to Arabic:
- Workspace settings (locale: `ar-SA`, html_lang: `ar`)
- Workspace titles
- Page names and settings
- Category names and descriptions
- Post titles and content
- Author information
- Link titles
- Newsletter names

**Important:** This migration is idempotent (safe to run multiple times) and only updates fields that match default English patterns.

## Key Features

### Preserved Technical Fields
- Email addresses remain valid
- Slugs stay in Latin characters (for SEO-friendly URLs)
- UUIDs and IDs unchanged
- Password hashes intact
- Database relationships preserved

### Arabic Content Examples

#### Workspace Settings
```ruby
html_lang: 'ar'
locale: 'ar-SA'
```

#### Sample Post Titles
- "مرحباً بك في مدونتي" (Welcome to my blog)
- "مقدمة في تطوير الويب" (Introduction to web development)
- "أهمية القراءة في حياتنا" (Importance of reading)
- "عادات يومية للنجاح" (Daily habits for success)

#### Categories
- غير مصنف (Uncategorized)
- تكنولوجيا (Technology)
- ثقافة (Culture)
- تطوير شخصي (Personal Development)

#### Navigation Links
- الرئيسية (Home)
- المقالات (Posts)
- عن المدونة (About)
- اتصل بنا (Contact)

## Usage Commands

### Fresh Installation

```bash
# 1. Setup database (creates, migrates, seeds)
bin/rails db:setup

# Output will be in Arabic:
# 🌱 البدء في إنشاء البيانات الافتراضية...
# ✓ تم إنشاء المستخدم: admin@example.com
# ✓ تم إنشاء مساحة العمل: مساحة العمل الخاصة بي
# ...
```

### Reset Database (Development)

```bash
# Complete reset with Arabic data
bin/rails db:reset

# This will:
# 1. Drop the database
# 2. Create new database
# 3. Run all migrations (including Arabic update migration)
# 4. Load Arabic seed data
```

### Update Existing Database

```bash
# Run the migration to update existing data
bin/rails db:migrate

# This runs: 20251111181735_update_existing_data_to_arabic.rb
# Safe to run on existing installations
```

### Rollback to English (if needed)

```bash
# Rollback the Arabic update migration
bin/rails db:rollback

# Note: Only locale settings are reversed
# Content changes may need manual reversal
```

### Test with Fixtures

```bash
# Run tests with Arabic fixtures
bin/rails test

# All tests will use Arabic fixture data
```

## Default Credentials

After seeding, use these credentials:

**Email:** admin@example.com
**Password:** changeme

**⚠️ IMPORTANT:** Change the password immediately after first login!

## SEO Considerations

All Arabic content includes proper SEO metadata:
- `seo_title` - Arabic page titles
- `seo_description` - Arabic meta descriptions
- `og_title` - Arabic Open Graph titles
- `og_description` - Arabic Open Graph descriptions

URLs remain SEO-friendly with Latin slugs:
- `/blog` (not `/مدونتي`)
- `/posts/welcome-to-my-blog` (not `/posts/مرحباً-بك`)

## TipTap Editor Content

Sample posts include both HTML and JSON formats for the TipTap editor:
- `content_html` - Rendered Arabic HTML
- `content_json` - TipTap document structure with Arabic text

Example structure:
```json
{
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": { "level": 2 },
      "content": [{ "type": "text", "text": "مرحباً بكم" }]
    },
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "أهلاً وسهلاً..." }]
    }
  ]
}
```

## Testing Checklist

After running `bin/rails db:reset`, verify:

- [ ] Admin login works with default credentials
- [ ] Workspace displays in Arabic (مساحة العمل الخاصة بي)
- [ ] Page name is in Arabic (مدونتي)
- [ ] Categories show Arabic names
- [ ] Posts display Arabic titles and content
- [ ] Navigation links are in Arabic
- [ ] Author names appear in Arabic
- [ ] Locale is set to `ar-SA` in workspace settings
- [ ] HTML lang attribute is `ar`
- [ ] All content is RTL

## Troubleshooting

### Issue: Migration fails with model errors
**Solution:** Ensure all models are loaded:
```bash
RAILS_ENV=development bin/rails db:migrate
```

### Issue: Seed fails with validation errors
**Solution:** Check that all required fields are present:
```bash
bin/rails db:seed --trace
```

### Issue: Tests fail with fixture errors
**Solution:** Reload fixtures:
```bash
bin/rails db:fixtures:load FIXTURES_PATH=submodules/core/test/fixtures
```

### Issue: Arabic text displays as question marks
**Solution:** Ensure database encoding is UTF-8:
```bash
# Check encoding
bin/rails runner "puts ActiveRecord::Base.connection.encoding"

# Should output: utf8 or unicode
```

## Database Schema

The migration preserves all schema constraints:
- Foreign keys intact
- Unique indexes maintained
- NOT NULL constraints preserved
- Enum values unchanged

## Integration with i18n System

The seed data complements the i18n system:
- Seed data: Database content in Arabic
- i18n files: Interface translations in Arabic
- Together: Complete Arabic experience

## Future Considerations

### Multi-language Support
If you plan to support multiple languages later:
1. Keep slugs in Latin (already done)
2. Store locale with each piece of content
3. Consider translatable fields gem
4. Maintain separate seed files per locale

### Content Updates
To update seed content:
1. Edit `db/seeds.rb`
2. Run `bin/rails db:reset` (development only)
3. Commit changes to version control

### Production Deployment
For production:
1. Never run `db:reset` in production
2. Use `db:seed` only on empty database
3. Use migrations for data updates
4. Backup before running migrations

## References

- Main seed file: `/db/seeds.rb`
- Test fixtures: `/submodules/core/test/fixtures/`
- Migration: `/db/migrate/20251111181735_update_existing_data_to_arabic.rb`
- i18n files: `/config/locales/ar.yml` and `/submodules/core/config/locales/ar.yml`

## Summary

All seed data is now in Arabic, providing a complete RTL experience from the moment a fresh database is created. The implementation preserves technical integrity while delivering an authentic Arabic interface.

**Total Files Updated:** 11 fixture files + 1 seed file + 1 migration
**Lines of Arabic Content:** ~500+ lines across all files
**Arabic Locale:** ar-SA (Arabic - Saudi Arabia)
