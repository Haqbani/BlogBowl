# Migration to update existing English data to Arabic
# This migration is safe to run multiple times (idempotent)
# It updates user-facing content to Arabic while preserving technical fields

class UpdateExistingDataToArabic < ActiveRecord::Migration[8.0]
  def up
    # Update workspace settings to Arabic locale
    WorkspaceSetting.where(html_lang: 'en').update_all(html_lang: 'ar')
    WorkspaceSetting.where("locale LIKE 'en%'").update_all(locale: 'ar-SA')

    # Update workspace titles if they match default English patterns
    update_workspace_titles

    # Update page names if they match default English patterns
    update_page_names

    # Update page settings
    update_page_settings

    # Update category names if they match default English patterns
    update_category_names

    # Update post titles and content if they match default English patterns
    update_post_titles

    # Update author positions and descriptions
    update_author_info

    # Update link titles if they match default English patterns
    update_link_titles

    # Update newsletter names
    update_newsletter_names
  end

  def down
    # Reversing to English
    WorkspaceSetting.where(html_lang: 'ar').update_all(html_lang: 'en')
    WorkspaceSetting.where("locale LIKE 'ar%'").update_all(locale: 'en-US')

    # Note: We don't reverse individual content changes as they may have been
    # customized by users. Only locale settings are reversed.
  end

  private

  def update_workspace_titles
    workspace_translations = {
      'My Workspace' => 'مساحة العمل الخاصة بي',
      'Default Workspace' => 'مساحة العمل الافتراضية',
      'one' => 'مساحة العمل الأولى',
      'two' => 'مساحة العمل الثانية'
    }

    workspace_translations.each do |english, arabic|
      Workspace.where(title: english).update_all(title: arabic)
    end
  end

  def update_page_names
    page_translations = {
      'My blog' => 'مدونتي',
      'Blog' => 'مدونتي',
      'My Blog' => 'مدونتي'
    }

    page_translations.each do |english, arabic|
      Page.where(name: english).update_all(name: arabic)
    end
  end

  def update_page_settings
    PageSetting.where("title LIKE '%blog%' OR title LIKE '%Blog%'").find_each do |ps|
      ps.update_columns(
        title: ps.title&.gsub(/blog/i, 'مدونتي') || 'مدونتي',
        logo_text: 'مدونتي',
        copyright: ps.copyright&.gsub(/All rights reserved/i, 'جميع الحقوق محفوظة') || '© 2025 جميع الحقوق محفوظة'
      )
    end

    # Update generic SEO content
    PageSetting.where("seo_title LIKE '%MyText%' OR seo_title IS NULL").find_each do |ps|
      ps.update_columns(
        seo_title: 'مدونتي - مشاركة الأفكار والتجارب',
        seo_description: 'مدونة شخصية لمشاركة المقالات باللغة العربية'
      )
    end
  end

  def update_category_names
    category_translations = {
      'Uncategorized' => 'غير مصنف',
      'General' => 'عام',
      'Technology' => 'تكنولوجيا',
      'Culture' => 'ثقافة',
      'Personal' => 'شخصي',
      'Category 1' => 'التصنيف الأول',
      'Category 2' => 'التصنيف الثاني'
    }

    category_translations.each do |english, arabic|
      Category.where(name: english).update_all(name: arabic)
    end

    # Update category descriptions
    Category.where("description LIKE '%Category%' OR description IS NULL").find_each do |cat|
      cat.update_columns(
        description: "#{cat.name} - وصف التصنيف"
      )
    end
  end

  def update_post_titles
    post_translations = {
      'First Post' => 'المقال الأول',
      'Welcome Post' => 'مقال ترحيبي',
      'MyString' => 'عنوان المقال'
    }

    post_translations.each do |english, arabic|
      Post.where(title: english).update_all(title: arabic)
    end

    # Update posts with generic content
    Post.where("title LIKE '%MyString%'").find_each do |post|
      post.update_columns(
        title: "المقال رقم #{post.id}",
        description: 'وصف المقال',
        content_html: '<p>محتوى المقال باللغة العربية.</p>'
      )
    end

    # Update welcome/intro posts
    Post.where("content_html LIKE '%Welcome to my blog%' OR content_html LIKE '%welcome%'").find_each do |post|
      post.update_columns(
        title: 'مرحباً بك في مدونتي',
        description: 'مقال ترحيبي للزوار',
        content_html: '<h2>مرحباً بكم</h2><p>أهلاً وسهلاً بكم في مدونتي الشخصية.</p>',
        seo_title: 'مرحباً بك في مدونتي',
        seo_description: 'مقال ترحيبي يعرف بالمدونة'
      )
    end
  end

  def update_author_info
    # Update author positions
    Author.where("position IS NULL OR position = ''").update_all(position: 'كاتب ومدون')

    Author.find_each do |author|
      updates = {}

      if author.position.present?
        position_translations = {
          'Writer' => 'كاتب',
          'Author' => 'مؤلف',
          'Editor' => 'محرر',
          'Blogger' => 'مدون'
        }

        position_translations.each do |eng, ar|
          if author.position.include?(eng)
            updates[:position] = author.position.gsub(eng, ar)
          end
        end
      end

      if author.short_description.present? && author.short_description.match?(/[a-zA-Z]/)
        updates[:short_description] = 'كاتب مهتم بالتكنولوجيا والثقافة'
      end

      if author.long_description.present? && author.long_description.match?(/[a-zA-Z]/)
        updates[:long_description] = 'كاتب ومدون عربي مهتم بالتكنولوجيا، الثقافة، والتطوير الشخصي.'
      end

      author.update_columns(updates) if updates.any?
    end
  end

  def update_link_titles
    link_translations = {
      'Home' => 'الرئيسية',
      'About' => 'عن المدونة',
      'Contact' => 'اتصل بنا',
      'Posts' => 'المقالات',
      'Blog' => 'المدونة',
      'General' => 'عام',
      'Privacy' => 'الخصوصية',
      'Terms' => 'الشروط',
      'Privacy Policy' => 'سياسة الخصوصية',
      'Terms of Service' => 'شروط الخدمة'
    }

    link_translations.each do |english, arabic|
      Link.where(title: english).update_all(title: arabic)
    end
  end

  def update_newsletter_names
    newsletter_translations = {
      'Default Newsletter' => 'النشرة الإخبارية الافتراضية',
      'Newsletter' => 'النشرة الإخبارية'
    }

    newsletter_translations.each do |english, arabic|
      Newsletter.where(name: english).update_all(name: arabic)
    end
  end
end
