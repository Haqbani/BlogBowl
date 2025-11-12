# BlogBowl Testing - Issues Summary

## Quick Reference

### Critical Issues (Must Fix)
1. ❌ **Post Publishing Fails** - "Slug can't be blank" validation error
2. ❌ **SVG viewBox Parsing** - JavaScript console error on every page
3. ❌ **Image URLs Broken** - Active Storage images fail to load

### Major Issues (High Priority)
4. ⚠️ **Duplicate Role Option** - Member role dropdown has duplicate "Owner"
5. ⚠️ **Non-Unique Element IDs** - Form elements share same ID

### Minor Issues (Nice to Have)
6. ℹ️ **Missing Autocomplete Attributes** - Accessibility warning
7. ℹ️ **Sidebar Z-index** - Publish button hard to click

---

## Issues at a Glance

| # | Issue | Severity | Impact | Blocker | Fix Time |
|---|-------|----------|--------|---------|----------|
| 1 | Post Publishing Fails | CRITICAL | Cannot publish posts | YES | 30 min |
| 2 | SVG viewBox Error | CRITICAL | Console errors, icon display | NO | 45 min |
| 3 | Image Loading Broken | CRITICAL | Images don't display | NO | 1 hr |
| 4 | Duplicate Role Option | MAJOR | UI confusion | NO | 15 min |
| 5 | Duplicate Element IDs | MAJOR | DOM conflicts | NO | 45 min |
| 6 | Missing Autocomplete | MINOR | Accessibility | NO | 15 min |
| 7 | Sidebar Z-index | MINOR | UX friction | NO | 20 min |

---

## Detailed Issues

### Issue #1: Post Publishing Fails with Slug Validation Error

**Status:** BLOCKING - Post publishing completely broken

**Error:**
```
HTTP 422 Unprocessable Entity
ActiveRecord::RecordInvalid: Validation failed: Slug can't be blank
```

**Root Cause:**
- Post revision apply() doesn't generate slug before save
- Slug validation fails because slug is required and blank
- Affects 100% of post publishing attempts

**Location:**
- `/submodules/core/app/models/concerns/models/post_revision_concern.rb` (line 13-17)

**Fix:**
```ruby
# Before (broken):
def apply!
  post.assign_attributes(...)
  post.generate_slug if post.title_changed? && post.slug.blank?
  post.save!
end

# After (fixed):
def apply!
  post.assign_attributes(...)
  post.generate_slug if post.slug.blank?  # Remove title_changed? check
  post.save!
end
```

**Test to Verify:**
1. Go to http://localhost:3000/pages/my-blog/posts
2. Click any post to edit
3. Click "Publish post" button
4. Should succeed with HTTP 200 response
5. Post should show "published" status

---

### Issue #2: SVG viewBox Parsing Error

**Status:** Non-blocking but visible in console

**Error:**
```
Error: <svg> attribute viewBox: Unexpected end of attribute. Expected number, "0 0 24".
File: http://localhost:3000/assets/submodules/core/javascript/application-95c6cd8b.js:30168
```

**Root Cause:**
- Malformed SVG icon with incomplete viewBox attribute
- Likely in icon library or React component

**Impact:**
- Console spam
- Possible icon rendering issues
- Error tracking systems alerted

**Fix Strategy:**
1. Search codebase for `viewBox="0 0"` or similar incomplete attributes
2. Check icon libraries in dependencies
3. Review React editor icon components
4. Rebuild JavaScript bundle

**Search Commands:**
```bash
grep -r "viewBox=" submodules/
grep -r "viewBox='0" .
find . -name "*.jsx" -o -name "*.tsx" | xargs grep -l "svg"
```

---

### Issue #3: Active Storage Image URLs Broken

**Status:** Non-blocking, affects user experience

**Error:**
```
Failed to load resource: net::ERR_CONNECTION_REFUSED @
http://localhost/rails/active_storage/blobs/redirect/...
```

**Root Cause:**
- Missing port in generated URL: `http://localhost` → should be `http://localhost:3000`
- Rails.application.routes.url_helpers.url_for() not configured for Docker environment

**Impact:**
- Post cover images not visible in editor
- Uploaded user images broken
- S3 fallback not working

**Fix:**
1. Check `/config/environments/production.rb`
2. Verify `config.action_controller.default_url_options`
3. Check Docker environment variables
4. May need to set RAILS_HOST or similar

**Likely Fix:**
```ruby
# In config/environments/production.rb
config.action_controller.default_url_options = {
  host: ENV['RAILS_HOST'] || 'localhost:3000',
  protocol: 'http'
}
```

---

### Issue #4: Duplicate Role Option in Member Edit

**Status:** Minor but affects UX

**Visible Issue:**
- Member edit form role dropdown shows:
  - Owner (selected)
  - Editor
  - Writer
  - Owner (duplicate!)

**Root Cause:**
- Enum or form options defined with duplicate values
- Likely in Member model or view template

**Location to Check:**
- `/submodules/core/app/models/member.rb` - enum definition
- `/submodules/core/app/views/members/` - form template

**Fix:**
Remove duplicate "Owner" option from role list

---

### Issue #5: Non-Unique Element IDs

**Status:** Accessibility violation

**Warning:**
```
[DOM] Found 2 elements with non-unique id #posts_role
```

**Impact:**
- WCAG accessibility violation
- JavaScript selector conflicts
- Form submission issues possible

**Fix Strategy:**
1. Find all `id="posts_role"` occurrences
2. Make IDs unique by adding identifier:
   ```erb
   <%= form.id = "posts_role_#{@member.id}" %>
   ```
3. Or use data attributes instead of IDs:
   ```erb
   <%= form.id = nil %>
   <div data-role="posts"></div>
   ```

---

### Issue #6: Missing Autocomplete Attributes

**Status:** Accessibility warning

**Warning:**
```
[DOM] Input elements should have autocomplete attributes
(suggested: "username")
```

**Location:**
- Member edit form (email, password fields)

**Fix:**
```html
<!-- Before -->
<input type="email" name="email" />

<!-- After -->
<input type="email" name="email" autocomplete="email" />

<!-- Password fields -->
<input type="password" autocomplete="current-password" />
<input type="password" autocomplete="new-password" />
```

---

### Issue #7: Sidebar Z-index Click Interception

**Status:** Minor UX issue

**Problem:**
- Publish button hard to click due to sidebar overlay
- Requires multiple attempts or JavaScript workaround
- Right sidebar with z-index 20 intercepts clicks

**Visual:**
```
[Post Editor Area]           [Sidebar with TOC]
                             z-index: 20 (overlays)
Publish Button
(hard to click)
```

**Fix:**
Adjust Tailwind CSS z-index values:
```css
/* Sidebar should be behind main content during interaction */
.sidebar { @apply relative z-10; }
.main-content { @apply relative z-20; }

/* OR hide sidebar on small screens */
@apply hidden lg:block
```

---

## Fix Priority Matrix

```
Impact/Priority
     ↑
HIGH │ Issue #1 ★★★
     │ Issue #2 ★★★
     │ Issue #3 ★★
     │           Issue #4 ★
     │           Issue #5 ★
     │           Issue #6
     │           Issue #7
     └─────────────────────────────→ Effort
    LO (15min)              (1hr)  HI
```

---

## Recommended Fix Schedule

### Immediate (Today)
- [ ] Issue #1: Post Publishing - 30 minutes
  - Apply fix to post_revision_concern.rb
  - Test that posts can be published
  - Verify slug generation works

### This Week
- [ ] Issue #2: SVG viewBox - 45 minutes
  - Locate malformed SVG
  - Fix viewBox attribute
  - Rebuild assets and test

- [ ] Issue #3: Image URLs - 1 hour
  - Configure Rails URL helpers
  - Test image loading in editor
  - Verify S3 fallback

- [ ] Issue #4: Duplicate Role - 15 minutes
- [ ] Issue #5: Duplicate IDs - 45 minutes

### This Sprint
- [ ] Issue #6: Autocomplete - 15 minutes
- [ ] Issue #7: Z-index - 20 minutes
- [ ] Full regression testing
- [ ] Update documentation

---

## Testing Checklist After Fixes

### Post Publishing
- [ ] Create new post
- [ ] Set title
- [ ] Set at least one author
- [ ] Click "Publish post"
- [ ] Verify success (no 422 error)
- [ ] Check post status changed to "published"
- [ ] Verify slug was generated

### Image Loading
- [ ] Upload cover image to post
- [ ] Verify image displays in editor
- [ ] Check browser console for errors
- [ ] Verify image path in page source

### Forms
- [ ] Check member edit form has unique element IDs
- [ ] Verify role dropdown shows only 3 options
- [ ] Test form submission

### Console Errors
- [ ] No SVG viewBox errors
- [ ] No image loading errors
- [ ] No duplicate ID warnings

---

## Known Working Features

✓ User authentication
✓ Workspace management
✓ Page creation and configuration
✓ Post editing and draft creation
✓ Category management
✓ Author management
✓ Settings and configuration
✓ Newsletter feature (disabled - expected)

---

## Known Broken Features

✗ Post publishing (Issue #1 - CRITICAL)
✗ Image loading (Issue #3 - HIGH)

---

## Database Health

- 1 User: admin@example.com
- 1 Workspace: My Workspace
- 1 Page: My blog (/blog)
- 6 Posts: 2 published, 4 draft
  - Note: One post missing author assignment
- 2 Authors: admin, Test Author
- 1 Category: test

**Recommendation:** Verify all published posts have authors before going live

---

## Security Notes

**Current State:**
- Default admin password still in use: "changeme"
- Authentication mechanism: BCrypt (secure)
- Authorization: CanCanCan gem (configured)

**Action Items:**
1. Change default admin password
2. Review CanCanCan abilities
3. Test role-based access control
4. Audit image upload restrictions

---

## Performance Notes

- Page load times: Acceptable (200-500ms)
- No obvious N+1 queries
- Editor responsiveness: Good
- No memory leaks observed

---

## Next Steps

1. **Triage:** Prioritize Issue #1 as blocking
2. **Fix:** Apply solution to post_revision_concern.rb
3. **Test:** Verify post publishing works
4. **Deploy:** Update staging environment
5. **Verify:** Run full test suite again
6. **Document:** Update CHANGELOG and release notes

---

**Report Generated:** November 11, 2025
**Total Issues Found:** 7 (3 Critical, 2 Major, 2 Minor)
**Status:** Ready for Development Team Review
