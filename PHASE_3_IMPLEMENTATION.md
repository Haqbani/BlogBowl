# Phase 3: i18n Configuration & Setup

**Status:** Ready to Implement  
**Estimated Time:** 4-6 hours  
**Priority:** HIGH - Required before Phase 4 (Translations)

---

## Overview

Phase 3 sets up Rails i18n (internationalization) framework to enable:
1. Multi-language support (English, Arabic)
2. Dynamic locale switching
3. Workspace-specific languages
4. Translation file management

---

## Step 1: Configure Rails i18n

### 1.1 Update `config/application.rb`

Add i18n configuration to the application class:

```ruby
# config/application.rb

module Blogbowl
  class Application < Rails::Application
    # ... existing config ...
    
    # i18n Configuration
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :ar]
    config.i18n.fallbacks = { ar: :en, en: :en }
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  end
end
```

### 1.2 Check Locale Files Structure

Create locale files directory if needed:
```
config/
└── locales/
    ├── en.yml           # English translations
    ├── ar.yml           # Arabic translations
    ├── admin/
    │   ├── en.yml
    │   └── ar.yml
    └── public/
        ├── en.yml
        └── ar.yml
```

---

## Step 2: Create Base Locale Files

### 2.1 English Base (`config/locales/en.yml`)

```yaml
en:
  activerecord:
    models:
      user: "User"
      post: "Post"
      page: "Page"
      workspace: "Workspace"
    attributes:
      user:
        email: "Email"
        password: "Password"
        password_confirmation: "Password Confirmation"
  
  errors:
    messages:
      blank: "can't be blank"
      invalid: "is invalid"
      taken: "has already been taken"
      
  devise:
    confirmations:
      confirmed: "Your email address has been successfully confirmed."
    mailer:
      confirmation_instructions:
        subject: "Confirmation instructions"
```

### 2.2 Arabic Base (`config/locales/ar.yml`)

```yaml
ar:
  activerecord:
    models:
      user: "المستخدم"
      post: "المقالة"
      page: "الصفحة"
      workspace: "مساحة العمل"
    attributes:
      user:
        email: "البريد الإلكتروني"
        password: "كلمة المرور"
        password_confirmation: "تأكيد كلمة المرور"
  
  errors:
    messages:
      blank: "لا يمكن أن يكون فارغاً"
      invalid: "غير صحيح"
      taken: "مأخوذ بالفعل"
      
  devise:
    confirmations:
      confirmed: "تم تأكيد عنوان بريدك الإلكتروني بنجاح."
    mailer:
      confirmation_instructions:
        subject: "تعليمات التأكيد"
```

---

## Step 3: Create Workspace Settings Model

### 3.1 Check Existing Model

```bash
grep -n "html_lang\|locale" submodules/core/app/models/workspace_settings.rb
```

If columns don't exist, create a migration:

```ruby
# submodules/core/db/migrate/XXXXXX_add_language_to_workspace_settings.rb

class AddLanguageToWorkspaceSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :workspace_settings, :locale, :string, default: 'en'
    add_column :workspace_settings, :html_lang, :string, default: 'en'
  end
end
```

### 3.2 Update WorkspaceSettings Model

```ruby
# submodules/core/app/models/workspace_settings.rb

class WorkspaceSettings < ApplicationRecord
  SUPPORTED_LOCALES = { 'en' => 'English', 'ar' => 'العربية' }.freeze
  
  validates :locale, inclusion: { in: SUPPORTED_LOCALES.keys }
  
  def html_lang
    self[:html_lang] || 'en'
  end
  
  def is_rtl?
    html_lang.start_with?('ar')
  end
end
```

---

## Step 4: Create Locale Switcher Controller

```ruby
# submodules/core/app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  before_action :set_locale
  
  protected
  
  def set_locale
    # For admin: allow query param to override user preference
    if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    elsif current_user&.locale.present?
      I18n.locale = current_user.locale
    else
      I18n.locale = I18n.default_locale
    end
  end
end
```

### For Public Pages:

```ruby
# In public page controller

def show
  @page = Page.find(params[:id])
  @workspace_settings = @page.workspace.settings
  
  # Set locale based on workspace setting
  I18n.locale = @workspace_settings.locale
end
```

---

## Step 5: Add Locale Switcher UI

### 5.1 Admin Navbar Switcher

```erb
<!-- submodules/core/app/views/shared/_locale_switcher.html.erb -->

<div class="dropdown dropdown-end">
  <button class="btn btn-sm btn-ghost">
    <%= t('language', default: 'Language') %>
  </button>
  <ul class="dropdown-content menu bg-base-100 rounded-box w-52">
    <% I18n.available_locales.each do |locale| %>
      <li>
        <%= link_to t("language_name_#{locale}", default: locale.to_s), 
            root_path(locale: locale),
            class: ('active' if I18n.locale == locale) %>
      </li>
    <% end %>
  </ul>
</div>
```

### 5.2 Add to Navbar

```erb
<!-- Add to _navbar.html.erb -->
<div class="flex items-center gap-2">
  <%= render 'shared/locale_switcher' %>
</div>
```

---

## Step 6: Translation Helpers

### 6.1 Add Translation Scope Helper

```ruby
# submodules/core/app/helpers/translation_helper.rb

module TranslationHelper
  def t_admin(key, options = {})
    I18n.t("admin.#{key}", options.merge(default: key.to_s))
  end
  
  def t_public(key, options = {})
    I18n.t("public.#{key}", options.merge(default: key.to_s))
  end
end
```

---

## Step 7: Create Initial Translation Files

### 7.1 Admin Strings (`config/locales/admin/en.yml`)

```yaml
en:
  admin:
    navigation:
      back_to_workspace: "Back to Workspace"
      page_management: "Page Management"
      page_settings: "Page Settings"
      new_post: "New Post"
      posts: "Posts"
      categories: "Categories"
      authors: "Authors"
      settings: "Settings"
    buttons:
      save: "Save"
      cancel: "Cancel"
      delete: "Delete"
      create: "Create"
```

### 7.2 Admin Strings (`config/locales/admin/ar.yml`)

```yaml
ar:
  admin:
    navigation:
      back_to_workspace: "العودة إلى مساحة العمل"
      page_management: "إدارة الصفحات"
      page_settings: "إعدادات الصفحة"
      new_post: "مقالة جديدة"
      posts: "المقالات"
      categories: "الفئات"
      authors: "المؤلفون"
      settings: "الإعدادات"
    buttons:
      save: "حفظ"
      cancel: "إلغاء"
      delete: "حذف"
      create: "إنشاء"
```

---

## Step 8: Testing i18n Setup

### 8.1 Create Test

```ruby
# test/integration/locale_test.rb

class LocaleTest < ActionDispatch::IntegrationTest
  test "en locale loads english content" do
    get root_path(locale: :en)
    assert_equal :en, I18n.locale
  end
  
  test "ar locale loads arabic content" do
    get root_path(locale: :ar)
    assert_equal :ar, I18n.locale
  end
  
  test "workspace respects locale setting" do
    workspace = workspaces(:one)
    workspace.settings.update(locale: :ar)
    
    get workspace_page_path(workspace, page: pages(:one))
    assert_equal :ar, I18n.locale
  end
end
```

### 8.2 Run Tests

```bash
bin/rails test test/integration/locale_test.rb
```

---

## Step 9: Seed Data Update

### 9.1 Add Locale Switching to Seeds

```ruby
# db/seeds.rb

# Update existing settings or create with locale
workspace = Workspace.first_or_create!(name: "Default")
workspace.settings.update!(
  locale: 'en',
  html_lang: 'en'
)

puts "✓ Workspace locale set to English"
```

---

## Verification Checklist

- [ ] `config/application.rb` has i18n configuration
- [ ] `config/locales/` directory exists with `en.yml` and `ar.yml`
- [ ] ApplicationController has `set_locale` before_action
- [ ] WorkspaceSettings model has `locale` and `html_lang` attributes
- [ ] Locale switcher renders in admin navbar
- [ ] I18n.locale changes correctly with URL param
- [ ] Database has locale for each workspace
- [ ] Tests pass for locale switching
- [ ] CSS builds without errors
- [ ] Sidebar positions correctly when dir attribute changes

---

## Next Steps After Phase 3

Once i18n is configured:

1. **Phase 4:** Translate all view template strings (300+)
2. **Phase 5:** Translate React editor components (150+)
3. **Phase 6:** Fix email templates and icon directions
4. **Phase 7:** Full testing and QA

---

## Troubleshooting

### Issue: "Missing translations"
**Solution:** Check locale file structure matches key paths

### Issue: "Locale not persisting"
**Solution:** Ensure `set_locale` is called on every request

### Issue: "HTML lang not changing"
**Solution:** Verify `dir` attribute changes when `lang` changes

---

## File Checklist for Phase 3

- [ ] `config/application.rb` - i18n config
- [ ] `config/locales/en.yml` - English base
- [ ] `config/locales/ar.yml` - Arabic base
- [ ] `app/helpers/translation_helper.rb` - Helper methods
- [ ] `app/views/shared/_locale_switcher.html.erb` - UI switcher
- [ ] `test/integration/locale_test.rb` - Tests
- [ ] Database migration (if needed) - Add locale columns

---

Generated by Claude Code | BlogBowl Phase 3 Implementation Guide
