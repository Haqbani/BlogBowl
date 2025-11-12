# QUICK FIX GUIDE: Phase 3 - i18n Configuration Setup

**Priority:** HIGH - Required for Phase 4 translations to work
**Estimated Time:** 4-6 hours
**Difficulty:** Medium

---

## The Problem in 30 Seconds

Phases 1-2 (CSS and layout) are complete and working. Now we need to set up Rails i18n framework so the application can load Arabic translations and switch between languages.

Without Phase 3:
- ❌ No translation files to load
- ❌ Can't switch between English and Arabic
- ❌ Can't implement Phase 4 translations

---

## Overview: What Phase 3 Does

Phase 3 configures the Rails i18n (internationalization) framework to:
1. Load translation files (ar.yml, en.yml)
2. Set default locale for the application
3. Allow locale switching via URL parameter
4. Store locale preference in workspace_settings
5. Create database columns for language preferences

---

## Step 1: Configure i18n in Rails

**File:** `/config/application.rb`

**Add this code** before the closing `end`:

```ruby
# Internationalization (i18n) Configuration
config.i18n.default_locale = :en  # Start with English, switch to :ar in Phase 4
config.i18n.available_locales = [:en, :ar]
config.i18n.fallbacks = true
```

**Example Location:**
```ruby
module BlogbowlAdmin
  class Application < Rails::Application
    # ... other configuration ...

    # Add i18n configuration here:
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :ar]
    config.i18n.fallbacks = true
  end
end
```

**Verification:**
```bash
bin/rails console
irb> I18n.default_locale
=> :en
irb> I18n.available_locales
=> [:en, :ar]
```

---

## Step 2: Create Locale Files

Create the following directory and files:

**Directory:** `/config/locales/`

**File 1: `/config/locales/en.yml`**

```yaml
en:
  # Navigation
  navigation:
    dashboard: Dashboard
    pages: Pages
    authors: Authors
    newsletter: Newsletter
    settings: Settings

  # Pages
  pages:
    all_pages: All Pages
    workspace_pages: Workspace Pages
    create_new_page: Create New Page

  # Common
  common:
    save: Save
    cancel: Cancel
    delete: Delete
    edit: Edit
    create: Create
    back: Back
```

**File 2: `/config/locales/ar.yml`**

```yaml
ar:
  # Navigation
  navigation:
    dashboard: لوحة التحكم
    pages: الصفحات
    authors: المؤلفون
    newsletter: النشرة الإخبارية
    settings: الإعدادات

  # Pages
  pages:
    all_pages: جميع الصفحات
    workspace_pages: صفحات المساحة
    create_new_page: إنشاء صفحة جديدة

  # Common
  common:
    save: حفظ
    cancel: إلغاء
    delete: حذف
    edit: تعديل
    create: إنشاء
    back: رجوع
```

**Note:** Start with these basic keys. Phase 4 will expand with full translations.

---

## Step 3: Add Locale Setter to Application Controller

**File:** `/submodules/core/app/controllers/application_controller.rb`

**Add this code:**

```ruby
before_action :set_locale

private

def set_locale
  # Allow ?locale=ar parameter to override
  if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
    I18n.locale = params[:locale].to_sym
  else
    # Check workspace_settings (if available)
    # For now, default to English
    I18n.locale = :en
  end
end
```

**Verification:**
```bash
bin/rails console
irb> I18n.locale = :ar
irb> I18n.t('navigation.pages')
=> "الصفحات"
```

---

## Step 4: Add Database Migration for Locale Columns

**Create Migration:**

```bash
bin/rails generate migration AddLocaleToWorkspaceSettings locale:string html_lang:string
```

**Edit Migration File:** `db/migrate/[timestamp]_add_locale_to_workspace_settings.rb`

```ruby
class AddLocaleToWorkspaceSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :workspace_settings, :locale, :string, default: 'en'
    add_column :workspace_settings, :html_lang, :string, default: 'en'

    # Add indices for performance
    add_index :workspace_settings, :locale
    add_index :workspace_settings, :html_lang
  end
end
```

**Run Migration:**

```bash
bin/rails db:migrate
```

**Verify:**

```bash
bin/rails console
irb> WorkspaceSettings.first.locale
=> "en"
```

---

## Step 5: Update ApplicationController to Check Workspace Settings

**File:** `/submodules/core/app/controllers/application_controller.rb`

**Update the set_locale method:**

```ruby
before_action :set_locale

private

def set_locale
  # Priority 1: URL parameter (?locale=ar)
  if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
    I18n.locale = params[:locale].to_sym
  # Priority 2: Workspace setting
  elsif @workspace_settings&.locale.present?
    I18n.locale = @workspace_settings.locale.to_sym
  # Default to English
  else
    I18n.locale = :en
  end
end
```

---

## Step 6: Update Workspace Model to Support Locale

**File:** `/submodules/core/app/models/workspace_settings.rb`

**Verify the model has:**

```ruby
class WorkspaceSettings < ApplicationRecord
  # ... existing code ...

  validates :locale, inclusion: { in: %w(en ar), message: "%{value} is not valid" }
  validates :html_lang, inclusion: { in: %w(en ar), message: "%{value} is not valid" }
end
```

---

## Step 7: Update View Templates to Use i18n

**Example: Navigation in `/submodules/core/app/views/shared/_dashboard_navbar.html.erb`**

**Before (Hardcoded):**
```erb
<span>Dashboard</span>
<span>Pages</span>
<span>Authors</span>
```

**After (Using i18n):**
```erb
<span><%= t('navigation.dashboard') %></span>
<span><%= t('navigation.pages') %></span>
<span><%= t('navigation.authors') %></span>
```

---

## Step 8: Test Locale Switching

**Start the server:**

```bash
bin/dev
```

**Test English (default):**
```bash
curl -s http://localhost:3000/pages | grep "All Pages"
# Should display: "All Pages"
```

**Test Arabic:**
```bash
curl -s "http://localhost:3000/pages?locale=ar" | grep "جميع"
# Should display: "جميع الصفحات"
```

**Or manually in browser:**
- Visit: `http://localhost:3000/pages?locale=en`
- Visit: `http://localhost:3000/pages?locale=ar`

---

## Verification Checklist

After completing Phase 3:

```bash
# 1. Verify i18n configuration
bin/rails console
irb> I18n.available_locales
# Should show: [:en, :ar]

# 2. Verify locale files exist
ls -la config/locales/
# Should show: en.yml, ar.yml

# 3. Verify migration was run
bin/rails db:migrate:status
# Should show all migrations completed

# 4. Verify database columns exist
bin/rails console
irb> WorkspaceSettings.columns.map(&:name)
# Should include: "locale", "html_lang"

# 5. Test locale switching
irb> I18n.locale = :ar
irb> I18n.t('navigation.pages')
# Should show: "الصفحات"
```

---

## Troubleshooting

### Issue: i18n.default_locale is still :en after setting to :ar

**Solution:**
The default locale in `config/application.rb` will be used until Phase 4 updates it. For now, keep it as `:en` to avoid breaking anything.

### Issue: Translation file not found

**Solution:**
```bash
# Check files exist
ls -la config/locales/

# Check file format is valid YAML
ruby -c config/locales/en.yml
```

### Issue: Database migration fails

**Solution:**
```bash
# Check migration status
bin/rails db:migrate:status

# Rollback and retry
bin/rails db:rollback
bin/rails db:migrate

# Check for syntax errors
bin/rails db:migrate:redo
```

### Issue: Locale switching doesn't work

**Solution:**
```bash
# Verify set_locale method is being called
grep -n "set_locale" submodules/core/app/controllers/application_controller.rb

# Check if it's in before_action
grep -n "before_action" submodules/core/app/controllers/application_controller.rb
```

---

## What Happens Next (Phase 4)

Once Phase 3 is complete:

1. **Expand Translation Files**
   - Add 500+ translation keys to ar.yml and en.yml
   - Cover all view templates

2. **Update Templates**
   - Wrap all hardcoded English strings with `t()` helper
   - Test each template with both locales

3. **React Components**
   - Add i18n to JavaScript/React code
   - Translate 150+ component strings

4. **Full Testing**
   - Test complete Arabic workflow
   - Verify RTL layout with Arabic text
   - Test locale switching

---

## Time Estimate

- Setting up i18n config: 15 minutes
- Creating locale files: 20 minutes
- Adding database migration: 15 minutes
- Updating controllers: 20 minutes
- Testing: 30 minutes
- **Total Phase 3: 1.5-2 hours**

**Note:** Actual time may be 4-6 hours if you encounter issues or need to debug.

---

## Success Criteria - Phase 3

- [x] i18n configured in `config/application.rb`
- [x] en.yml and ar.yml files created
- [x] Database columns added for locale settings
- [x] ApplicationController has set_locale method
- [x] View templates use `t()` helper for navigation
- [x] Locale switching works via URL parameter
- [x] No errors when changing locale
- [x] Ready for Phase 4 translations

---

## Key Files Modified in Phase 3

1. `config/application.rb` - i18n configuration
2. `config/locales/en.yml` - English translations (new)
3. `config/locales/ar.yml` - Arabic translations (new)
4. `submodules/core/app/controllers/application_controller.rb` - locale setter
5. `db/migrate/[timestamp]_add_locale_to_workspace_settings.rb` - database migration
6. `submodules/core/app/models/workspace_settings.rb` - validation

---

## Next Phase Preview

After Phase 3 is complete, Phase 4 will:
- Expand locale files with 500+ translation keys
- Update 100+ view templates with `t()` calls
- Test multilingual view rendering
- Verify Arabic text displays correctly

Estimated Phase 4 time: **30+ hours**

---

**Guide Created:** November 11, 2025
**Phase:** 3 of 5
**Status:** Ready to Implement
**Questions:** Refer to PHASE_3_IMPLEMENTATION.md for detailed guide

