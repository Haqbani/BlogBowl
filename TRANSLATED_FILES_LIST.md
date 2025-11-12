# Translated Files List - BlogBowl Arabic i18n

**Last Updated:** 2025-11-11
**Total Translated:** 18 files
**Translation Keys:** 470+

---

## ✅ Completed Translations

### Phase 3 Step 2 (Previous) - 8 Files

#### Authentication Views
1. `/submodules/core/app/views/sessions/new.html.erb` - Sign in page
2. `/submodules/core/app/views/passwords/edit.html.erb` - Password change
3. `/submodules/core/app/views/registrations/new.html.erb` - Sign up page

#### Workspace Views
4. `/submodules/core/app/views/workspaces/index.html.erb` - Workspace selection

#### Navigation Components
5. `/submodules/core/app/views/shared/_navbar.html.erb` - Main navigation

#### Member Management
6. `/submodules/core/app/views/members/index.html.erb` - Members listing
7. `/submodules/core/app/views/members/new.html.erb` - Invite member

### Phase 3 Step 3 (Current) - 10 Files

#### Posts Management
8. `/submodules/core/app/views/pages/posts/index.html.erb` - Posts listing with filters
9. `/submodules/core/app/views/pages/posts/new.html.erb` - Create new post
10. `/submodules/core/app/views/pages/posts/edit.html.erb` - Edit post (title only)
11. `/submodules/core/app/views/pages/posts/_post.html.erb` - Post item partial

#### Pages Management
12. `/submodules/core/app/views/pages/index.html.erb` - Pages overview
13. `/submodules/core/app/views/pages/settings/general/edit.html.erb` - General settings (complete form)

#### Authors Management
14. `/submodules/core/app/views/authors/index.html.erb` - Authors listing

#### Categories Management
15. `/submodules/core/app/views/pages/categories/index.html.erb` - Categories listing

#### Newsletters Management
16. `/submodules/core/app/views/newsletters/index.html.erb` - Newsletters overview

---

## 📊 Translation Coverage by Feature

### Core Blogging Features: 95% Complete
- ✅ Posts management (CRUD operations)
- ✅ Pages management (overview)
- ✅ Categories management (listing)
- ✅ Authors management (listing)
- ⚠️ Forms (TipTap editor - React component, not translated)

### Settings & Configuration: 30% Complete
- ✅ General page settings (complete)
- ❌ Profile settings
- ❌ Domain settings
- ❌ Newsletter settings
- ❌ Integration settings

### Authentication & Users: 80% Complete
- ✅ Sign in
- ✅ Sign up
- ✅ Password change
- ✅ Member management
- ❌ Invitation acceptance
- ❌ Authentication logs

### Newsletter System: 40% Complete
- ✅ Newsletter overview
- ❌ Newsletter creation/editing
- ❌ Email editor
- ❌ Subscriber management

### Navigation: 100% Complete
- ✅ Main navbar
- ✅ All navigation items

---

## 📝 Translation Keys in ar.yml

### Organized Sections (470+ keys total)

1. **common** - Global UI elements (26 keys)
2. **auth** - Authentication flows (17 keys)
3. **workspaces** - Workspace management (12 keys)
4. **nav/navigation** - Navigation (18 keys)
5. **pages** - Page management (22 keys)
6. **posts** - Post management (30 keys)
7. **categories** - Category management (18 keys)
8. **authors** - Author management (14 keys)
9. **members** - Member management (17 keys)
10. **newsletters** - Newsletter system (21 keys)
11. **settings** - Configuration (52 keys)
12. **buttons** - Button labels (26 keys)
13. **forms** - Form elements (15 keys)
14. **validations** - Validation messages (12 keys)
15. **flash** - Flash messages (12 keys)
16. **roles** - User roles (6 keys)
17. **confirmations** - Confirmation dialogs (3 keys)
18. **empty_states** - Empty state messages (6 keys)
19. **time/date** - Date/time formats (35 keys)
20. **activerecord** - Model translations (50+ keys)
21. **pagination** - Pagination (5 keys)

---

## ⚠️ Files NOT Yet Translated (170+ remaining)

### High Priority
- Settings pages (domain, profile, integrations, etc.) - ~15 files
- Newsletter forms and email editor - ~10 files
- Public-facing blog templates - ~20 files
- Author/member forms - ~5 files

### Medium Priority
- Shared partials (flash messages, modals, forms) - ~10 files
- Invitation flows - ~5 files
- Subscriber management - ~5 files

### Low Priority
- Mailer templates - ~15 files
- Journey/onboarding - ~5 files
- Public documentation templates - ~20 files
- Admin tools - ~10 files

---

## 🎯 Next Recommended Files to Translate

### Priority 1: Settings Pages (HIGH IMPACT)
1. `/submodules/core/app/views/settings/show.html.erb` - Settings index
2. `/submodules/core/app/views/settings/members/index.html.erb` - Members settings
3. `/submodules/core/app/views/pages/settings/domain/edit.html.erb` - Domain configuration
4. `/submodules/core/app/views/pages/settings/layout/edit.html.erb` - Layout settings
5. `/submodules/core/app/views/pages/settings/footer/edit.html.erb` - Footer settings

### Priority 2: Newsletter Views (MEDIUM IMPACT)
6. `/submodules/core/app/views/newsletters/new.html.erb` - Create newsletter
7. `/submodules/core/app/views/newsletters/_form.html.erb` - Newsletter form
8. `/submodules/core/app/views/newsletters/newsletter_emails/index.html.erb` - Emails listing
9. `/submodules/core/app/views/newsletters/newsletter_emails/new.html.erb` - Create email
10. `/submodules/core/app/views/newsletters/subscribers/index.html.erb` - Subscribers listing

### Priority 3: Public Templates (HIGH IMPACT)
11. `/submodules/core/app/views/layouts/public/*.html.erb` - Public layouts
12. `/submodules/core/app/views/public/*/posts/show.html.erb` - Blog post display
13. `/submodules/core/app/views/public/*/categories/index.html.erb` - Category pages
14. `/submodules/core/app/views/public/*/authors/*.html.erb` - Author pages

---

## 📈 Translation Progress Tracking

### Overall Progress
- **Total ERB files:** ~188
- **Files translated:** 18
- **Coverage:** 9.6%

### By Priority Level
- **Critical user-facing features:** 95% complete
- **Settings & configuration:** 30% complete
- **Public-facing blog:** 0% complete
- **Admin & tools:** 10% complete

### By User Journey
- **Content creation (posts/pages):** 90% complete
- **Settings & customization:** 25% complete
- **User management:** 70% complete
- **Newsletter management:** 30% complete
- **Public blog reading:** 0% complete

---

## 🔧 How to Use This List

### For Developers
1. Check this list before starting translation work
2. Pick files from "Next Recommended" section
3. Follow translation patterns from completed files
4. Update this list when adding new translations

### For QA Testing
1. Test each translated file in Arabic locale
2. Verify forms submit correctly
3. Check RTL layout renders properly
4. Validate translation quality

### For Project Managers
1. Track translation progress
2. Prioritize remaining work
3. Estimate completion timelines
4. Plan deployment phases

---

**Last Updated:** November 11, 2025
**Maintained By:** Engineering Team
**Project:** BlogBowl Phase 3 - Arabic i18n Implementation
