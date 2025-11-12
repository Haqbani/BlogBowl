# Arabic Setup Quick Start Guide

## For Fresh Installation

```bash
# 1. Start development infrastructure (PostgreSQL + Redis)
docker compose -f docker-compose.dev.yaml up -d

# 2. Setup database with Arabic data
bin/rails db:setup

# 3. Start development server
bin/dev

# 4. Login
# Email: admin@example.com
# Password: changeme
```

You should see Arabic output:
```
🌱 البدء في إنشاء البيانات الافتراضية...
✓ تم إنشاء المستخدم: admin@example.com
✓ تم إنشاء مساحة العمل: مساحة العمل الخاصة بي
✓ تم إنشاء الصفحة: مدونتي
✅ تم إنشاء البيانات بنجاح!
```

## For Existing Database

```bash
# Update existing data to Arabic
bin/rails db:migrate

# Or reset completely (development only!)
bin/rails db:reset
```

## Verify Arabic Setup

After seeding, check:

1. **Workspace Settings**
   - Navigate to Settings → Workspace
   - Should see: `html_lang: ar`, `locale: ar-SA`

2. **Content**
   - Workspace: "مساحة العمل الخاصة بي"
   - Page: "مدونتي"
   - Categories: "غير مصنف", "تكنولوجيا", "ثقافة", "تطوير شخصي"
   - Posts: Arabic titles and content

3. **UI Direction**
   - All content should be right-to-left
   - Navigation should be reversed
   - Text should align to the right

## What Was Changed

### Database Seeds (`db/seeds.rb`)
- Complete Arabic blog setup
- 4 sample posts with rich content
- Arabic categories and navigation
- Workspace locale: `ar-SA`

### Test Fixtures (`submodules/core/test/fixtures/`)
- All 11 fixture files updated to Arabic
- Locale changed to `ar-SA`
- Names, titles, descriptions in Arabic

### Migration (`db/migrate/20251111181735_update_existing_data_to_arabic.rb`)
- Updates existing English data
- Changes locale to `ar-SA`
- Safe to run multiple times

## Key Preserved Elements

✓ Email addresses (remain valid)
✓ Slugs (Latin for SEO-friendly URLs)
✓ UUIDs and IDs
✓ Password hashes
✓ Database relationships
✓ Technical configurations

## Sample Content Created

### Posts
1. **مرحباً بك في مدونتي** (Welcome to my blog)
2. **مقدمة في تطوير الويب** (Introduction to web development)
3. **أهمية القراءة في حياتنا** (Importance of reading)
4. **عادات يومية للنجاح** (Daily habits for success)

### Categories
- غير مصنف (Uncategorized) - Gray
- تكنولوجيا (Technology) - Blue
- ثقافة (Culture) - Purple
- تطوير شخصي (Personal Development) - Green

### Navigation Links
- الرئيسية (Home)
- المقالات (Posts)
- عن المدونة (About)
- اتصل بنا (Contact)

### Footer Links
- سياسة الخصوصية (Privacy Policy)
- شروط الاستخدام (Terms of Service)

## Default Admin Credentials

**Email:** admin@example.com
**Password:** changeme

**⚠️ Change password after first login!**

## Troubleshooting

### Database connection error
```bash
# Start PostgreSQL
docker compose -f docker-compose.dev.yaml up -d
```

### Arabic text shows as ????
```bash
# Check database encoding
bin/rails runner "puts ActiveRecord::Base.connection.encoding"
# Should show: utf8 or unicode
```

### Migration fails
```bash
# Run with trace
bin/rails db:migrate --trace
```

## Testing

```bash
# Run tests with Arabic fixtures
bin/rails test

# All tests use Arabic data from fixtures
```

## Production Deployment

⚠️ **NEVER** run `db:reset` in production!

For production:
```bash
# Only run migrations
bin/rails db:migrate RAILS_ENV=production

# Seed only on empty database
bin/rails db:seed RAILS_ENV=production
```

## Related Documentation

- Full documentation: `ARABIC_SEED_DATA.md`
- i18n configuration: `config/locales/ar.yml`
- RTL styling: `submodules/core/app/assets/stylesheets/`

## Success Checklist

After setup, you should have:
- ✅ Arabic admin interface
- ✅ Arabic workspace (ar-SA locale)
- ✅ Arabic blog page
- ✅ 4 categories in Arabic
- ✅ 4 sample posts in Arabic
- ✅ Arabic navigation
- ✅ RTL layout everywhere
- ✅ Arabic SEO metadata

## Next Steps

1. Login with default credentials
2. **Change password immediately**
3. Update workspace title if needed
4. Customize categories and posts
5. Add your own Arabic content
6. Configure domain settings
7. Set up newsletter (optional)

## Need Help?

Check `ARABIC_SEED_DATA.md` for:
- Detailed migration documentation
- Content structure explanation
- Advanced troubleshooting
- Integration with i18n system
- Multi-language considerations

---

**Ready to use BlogBowl in Arabic!** 🎉
