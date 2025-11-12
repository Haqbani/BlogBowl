# Seed file for BlogBowl - Arabic RTL version
# This creates a default workspace with Arabic content

puts "🌱 البدء في إنشاء البيانات الافتراضية..."

ActiveRecord::Base.transaction do
  # Create default admin user
  puts "👤 إنشاء المستخدم الافتراضي..."
  user = User.find_or_create_by!(email: "admin@example.com") do |u|
    u.password = "changeme"
    u.first_name = "أحمد"
    u.last_name = "المدير"
  end
  puts "✓ تم إنشاء المستخدم: admin@example.com"

  # Create default workspace
  puts "🏢 إنشاء مساحة العمل الافتراضية..."
  workspace = Workspace.find_or_create_by!(title: "مساحة العمل الخاصة بي") do |w|
    w.uuid = SecureRandom.uuid
  end
  puts "✓ تم إنشاء مساحة العمل: #{workspace.title}"

  # Create workspace settings with Arabic locale
  puts "⚙️  إنشاء إعدادات مساحة العمل..."
  workspace_settings = WorkspaceSetting.find_or_create_by!(workspace: workspace) do |ws|
    ws.html_lang = 'ar'
    ws.locale = 'ar-SA'
    ws.title = 'مساحة العمل الخاصة بي'
    ws.with_watermark = true
  end
  puts "✓ تم إنشاء إعدادات مساحة العمل (اللغة: ar-SA)"

  # Create member relationship
  puts "👥 إنشاء عضوية المستخدم..."
  member = Member.find_or_create_by!(user: user, workspace: workspace) do |m|
    m.permissions = ['admin']
  end
  puts "✓ تم إنشاء العضوية"

  # Create default blog page
  puts "📄 إنشاء صفحة المدونة..."
  page = Page.find_or_create_by!(workspace: workspace, slug: 'blog') do |p|
    p.name = 'مدونتي'
    p.name_slug = 'blog'
  end
  puts "✓ تم إنشاء الصفحة: #{page.name}"

  # Create page settings
  puts "⚙️  إنشاء إعدادات الصفحة..."
  page_settings = PageSetting.find_or_create_by!(page: page) do |ps|
    ps.seo_title = 'مدونتي - مشاركة أفكاري وتجاربي'
    ps.seo_description = 'مدونة شخصية لمشاركة المقالات والأفكار باللغة العربية'
    ps.title = 'مدونتي'
    ps.description = 'مرحباً بك في مدونتي الشخصية'
    ps.template = 'basic'
    ps.logo_text = 'مدونتي'
    ps.copyright = '© 2025 جميع الحقوق محفوظة'
    ps.with_sitemap = true
    ps.with_search = true
    ps.with_rss = true
  end
  puts "✓ تم إنشاء إعدادات الصفحة"

  # Create default author
  puts "✍️  إنشاء المؤلف الافتراضي..."
  author = Author.find_or_create_by!(member: member, email: user.email) do |a|
    a.first_name = 'أحمد'
    a.last_name = 'المدير'
    a.position = 'كاتب ومدون'
    a.short_description = 'كاتب مهتم بالتكنولوجيا والثقافة'
    a.long_description = 'كاتب ومدون عربي مهتم بالتكنولوجيا، الثقافة، والتطوير الشخصي. أكتب لمشاركة تجاربي وأفكاري مع القراء.'
    a.active = true
    a.slug = 'ahmed-admin'
  end
  puts "✓ تم إنشاء المؤلف: #{author.first_name} #{author.last_name}"

  # Create default categories
  puts "🗂️  إنشاء التصنيفات..."
  categories = []

  uncategorized = Category.find_or_create_by!(page: page, name: 'غير مصنف', parent_id: nil) do |c|
    c.description = 'المقالات غير المصنفة'
    c.slug = 'uncategorized'
    c.color = '#6B7280'
  end
  categories << uncategorized
  puts "  ✓ #{uncategorized.name}"

  tech_category = Category.find_or_create_by!(page: page, name: 'تكنولوجيا', parent_id: nil) do |c|
    c.description = 'مقالات عن التكنولوجيا والبرمجة'
    c.slug = 'technology'
    c.color = '#3B82F6'
  end
  categories << tech_category
  puts "  ✓ #{tech_category.name}"

  culture_category = Category.find_or_create_by!(page: page, name: 'ثقافة', parent_id: nil) do |c|
    c.description = 'مقالات ثقافية ومعرفية'
    c.slug = 'culture'
    c.color = '#8B5CF6'
  end
  categories << culture_category
  puts "  ✓ #{culture_category.name}"

  personal_category = Category.find_or_create_by!(page: page, name: 'تطوير شخصي', parent_id: nil) do |c|
    c.description = 'مقالات عن التطوير الذاتي والنمو الشخصي'
    c.slug = 'personal-development'
    c.color = '#10B981'
  end
  categories << personal_category
  puts "  ✓ #{personal_category.name}"

  # Create sample posts
  puts "📝 إنشاء المقالات النموذجية..."

  # Welcome post
  welcome_post = Post.find_or_create_by!(page: page, slug: 'welcome-to-my-blog') do |p|
    p.title = 'مرحباً بك في مدونتي'
    p.description = 'مقال ترحيبي للزوار الجدد'
    p.content_html = '<h2>مرحباً بكم</h2><p>أهلاً وسهلاً بكم في مدونتي الشخصية. هنا أشارك أفكاري وتجاربي في مجالات مختلفة مثل التكنولوجيا، الثقافة، والتطوير الشخصي.</p><p>آمل أن تجدوا محتوى مفيداً وممتعاً في هذه المدونة.</p>'
    p.content_json = {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 2 },
          content: [{ type: 'text', text: 'مرحباً بكم' }]
        },
        {
          type: 'paragraph',
          content: [{ type: 'text', text: 'أهلاً وسهلاً بكم في مدونتي الشخصية. هنا أشارك أفكاري وتجاربي في مجالات مختلفة مثل التكنولوجيا، الثقافة، والتطوير الشخصي.' }]
        },
        {
          type: 'paragraph',
          content: [{ type: 'text', text: 'آمل أن تجدوا محتوى مفيداً وممتعاً في هذه المدونة.' }]
        }
      ]
    }
    p.seo_title = 'مرحباً بك في مدونتي'
    p.seo_description = 'مقال ترحيبي يعرف بالمدونة ومحتواها'
    p.status = :published
    p.first_published_at = Time.current
    p.category = uncategorized
  end
  PostAuthor.find_or_create_by!(post: welcome_post, author: author) do |pa|
    pa.role = :primary
  end
  puts "  ✓ #{welcome_post.title}"

  # Tech post
  tech_post = Post.find_or_create_by!(page: page, slug: 'introduction-to-web-development') do |p|
    p.title = 'مقدمة في تطوير الويب'
    p.description = 'نظرة عامة على تطوير تطبيقات الويب الحديثة'
    p.content_html = '<h2>تطوير الويب الحديث</h2><p>تطوير الويب مجال متطور باستمرار. في هذا المقال، سنتعرف على الأساسيات والأدوات الحديثة المستخدمة في تطوير تطبيقات الويب.</p><h3>التقنيات الأساسية</h3><ul><li>HTML5 - لغة ترميز الصفحات</li><li>CSS3 - تنسيق وتصميم الصفحات</li><li>JavaScript - البرمجة التفاعلية</li></ul><p>هذه التقنيات تشكل أساس تطوير الويب الحديث.</p>'
    p.content_json = {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 2 },
          content: [{ type: 'text', text: 'تطوير الويب الحديث' }]
        },
        {
          type: 'paragraph',
          content: [{ type: 'text', text: 'تطوير الويب مجال متطور باستمرار. في هذا المقال، سنتعرف على الأساسيات والأدوات الحديثة المستخدمة في تطوير تطبيقات الويب.' }]
        },
        {
          type: 'heading',
          attrs: { level: 3 },
          content: [{ type: 'text', text: 'التقنيات الأساسية' }]
        },
        {
          type: 'bulletList',
          content: [
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'HTML5 - لغة ترميز الصفحات' }] }] },
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'CSS3 - تنسيق وتصميم الصفحات' }] }] },
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'JavaScript - البرمجة التفاعلية' }] }] }
          ]
        },
        {
          type: 'paragraph',
          content: [{ type: 'text', text: 'هذه التقنيات تشكل أساس تطوير الويب الحديث.' }]
        }
      ]
    }
    p.seo_title = 'مقدمة في تطوير الويب - دليل المبتدئين'
    p.seo_description = 'تعرف على أساسيات تطوير الويب والتقنيات المستخدمة في بناء تطبيقات الويب الحديثة'
    p.status = :published
    p.first_published_at = 1.day.ago
    p.category = tech_category
  end
  PostAuthor.find_or_create_by!(post: tech_post, author: author) do |pa|
    pa.role = :primary
  end
  puts "  ✓ #{tech_post.title}"

  # Culture post
  culture_post = Post.find_or_create_by!(page: page, slug: 'importance-of-reading') do |p|
    p.title = 'أهمية القراءة في حياتنا'
    p.description = 'كيف تساهم القراءة في تطوير شخصيتنا وتوسيع مداركنا'
    p.content_html = '<h2>القراءة غذاء العقل</h2><p>القراءة من أهم العادات التي يمكن أن نمارسها في حياتنا اليومية. إنها تفتح لنا نوافذ على عوالم جديدة وتساعدنا على فهم الآخرين بشكل أفضل.</p><h3>فوائد القراءة</h3><p>للقراءة فوائد عديدة منها:</p><ol><li>توسيع المعرفة والثقافة</li><li>تحسين مهارات التفكير النقدي</li><li>تطوير مهارات اللغة والتواصل</li><li>تقليل التوتر والاسترخاء</li></ol><p>ابدأ بتخصيص وقت يومي للقراءة، ولو لبضع دقائق.</p>'
    p.content_json = {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 2 },
          content: [{ type: 'text', text: 'القراءة غذاء العقل' }]
        },
        {
          type: 'paragraph',
          content: [{ type: 'text', text: 'القراءة من أهم العادات التي يمكن أن نمارسها في حياتنا اليومية. إنها تفتح لنا نوافذ على عوالم جديدة وتساعدنا على فهم الآخرين بشكل أفضل.' }]
        },
        {
          type: 'heading',
          attrs: { level: 3 },
          content: [{ type: 'text', text: 'فوائد القراءة' }]
        },
        {
          type: 'paragraph',
          content: [{ type: 'text', text: 'للقراءة فوائد عديدة منها:' }]
        },
        {
          type: 'orderedList',
          content: [
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'توسيع المعرفة والثقافة' }] }] },
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'تحسين مهارات التفكير النقدي' }] }] },
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'تطوير مهارات اللغة والتواصل' }] }] },
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'تقليل التوتر والاسترخاء' }] }] }
          ]
        },
        {
          type: 'paragraph',
          content: [{ type: 'text', text: 'ابدأ بتخصيص وقت يومي للقراءة، ولو لبضع دقائق.' }]
        }
      ]
    }
    p.seo_title = 'أهمية القراءة في حياتنا اليومية'
    p.seo_description = 'اكتشف فوائد القراءة وكيف تساهم في تطوير شخصيتك وتوسيع آفاقك المعرفية'
    p.status = :published
    p.first_published_at = 2.days.ago
    p.category = culture_category
  end
  PostAuthor.find_or_create_by!(post: culture_post, author: author) do |pa|
    pa.role = :primary
  end
  puts "  ✓ #{culture_post.title}"

  # Personal development post
  personal_post = Post.find_or_create_by!(page: page, slug: 'daily-habits-for-success') do |p|
    p.title = 'عادات يومية للنجاح'
    p.description = 'عادات بسيطة يمكن أن تحدث فرقاً كبيراً في حياتك'
    p.content_html = '<h2>بناء عادات النجاح</h2><p>النجاح ليس حدثاً واحداً، بل هو نتيجة عادات يومية صغيرة نمارسها باستمرار. في هذا المقال، سنتعرف على عادات بسيطة يمكن أن تساعدك على تحقيق أهدافك.</p><h3>العادات الأساسية</h3><ol><li><strong>الاستيقاظ المبكر:</strong> ابدأ يومك بنشاط وتركيز</li><li><strong>التخطيط اليومي:</strong> حدد أهدافك لليوم</li><li><strong>ممارسة الرياضة:</strong> حافظ على صحتك الجسدية</li><li><strong>القراءة:</strong> تعلم شيئاً جديداً كل يوم</li><li><strong>التأمل:</strong> راجع إنجازاتك قبل النوم</li></ol><p>ابدأ بعادة واحدة واستمر عليها لمدة 21 يوماً حتى تصبح جزءاً من روتينك.</p>'
    p.content_json = {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 2 },
          content: [{ type: 'text', text: 'بناء عادات النجاح' }]
        },
        {
          type: 'paragraph',
          content: [{ type: 'text', text: 'النجاح ليس حدثاً واحداً، بل هو نتيجة عادات يومية صغيرة نمارسها باستمرار. في هذا المقال، سنتعرف على عادات بسيطة يمكن أن تساعدك على تحقيق أهدافك.' }]
        },
        {
          type: 'heading',
          attrs: { level: 3 },
          content: [{ type: 'text', text: 'العادات الأساسية' }]
        },
        {
          type: 'orderedList',
          content: [
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'الاستيقاظ المبكر: ', marks: [{ type: 'bold' }] }, { type: 'text', text: 'ابدأ يومك بنشاط وتركيز' }] }] },
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'التخطيط اليومي: ', marks: [{ type: 'bold' }] }, { type: 'text', text: 'حدد أهدافك لليوم' }] }] },
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'ممارسة الرياضة: ', marks: [{ type: 'bold' }] }, { type: 'text', text: 'حافظ على صحتك الجسدية' }] }] },
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'القراءة: ', marks: [{ type: 'bold' }] }, { type: 'text', text: 'تعلم شيئاً جديداً كل يوم' }] }] },
            { type: 'listItem', content: [{ type: 'paragraph', content: [{ type: 'text', text: 'التأمل: ', marks: [{ type: 'bold' }] }, { type: 'text', text: 'راجع إنجازاتك قبل النوم' }] }] }
          ]
        },
        {
          type: 'paragraph',
          content: [{ type: 'text', text: 'ابدأ بعادة واحدة واستمر عليها لمدة 21 يوماً حتى تصبح جزءاً من روتينك.' }]
        }
      ]
    }
    p.seo_title = 'عادات يومية للنجاح - دليل التطوير الشخصي'
    p.seo_description = 'تعرف على العادات اليومية البسيطة التي يمكن أن تحدث تغييراً إيجابياً في حياتك وتساعدك على تحقيق النجاح'
    p.status = :published
    p.first_published_at = 3.days.ago
    p.category = personal_category
  end
  PostAuthor.find_or_create_by!(post: personal_post, author: author) do |pa|
    pa.role = :primary
  end
  puts "  ✓ #{personal_post.title}"

  # Create header links
  puts "🔗 إنشاء روابط التنقل..."
  Link.find_or_create_by!(page: page, title: 'الرئيسية', location: 'header') do |l|
    l.url = '/'
    l.link_type = 'link'
    l.order = 1
  end

  Link.find_or_create_by!(page: page, title: 'المقالات', location: 'header') do |l|
    l.url = '/posts'
    l.link_type = 'link'
    l.order = 2
  end

  Link.find_or_create_by!(page: page, title: 'عن المدونة', location: 'header') do |l|
    l.url = '/about'
    l.link_type = 'link'
    l.order = 3
  end

  Link.find_or_create_by!(page: page, title: 'اتصل بنا', location: 'header') do |l|
    l.url = '/contact'
    l.link_type = 'link'
    l.order = 4
  end
  puts "✓ تم إنشاء روابط التنقل"

  # Create footer links
  puts "🔗 إنشاء روابط التذييل..."
  Link.find_or_create_by!(page: page, title: 'سياسة الخصوصية', location: 'footer') do |l|
    l.url = '/privacy'
    l.link_type = 'link'
    l.order = 1
  end

  Link.find_or_create_by!(page: page, title: 'شروط الاستخدام', location: 'footer') do |l|
    l.url = '/terms'
    l.link_type = 'link'
    l.order = 2
  end
  puts "✓ تم إنشاء روابط التذييل"

  puts ""
  puts "✅ تم إنشاء البيانات بنجاح!"
  puts ""
  puts "📊 ملخص البيانات المنشأة:"
  puts "  • المستخدمون: #{User.count}"
  puts "  • مساحات العمل: #{Workspace.count}"
  puts "  • الصفحات: #{Page.count}"
  puts "  • المقالات: #{Post.count}"
  puts "  • التصنيفات: #{Category.count}"
  puts "  • المؤلفون: #{Author.count}"
  puts "  • الروابط: #{Link.count}"
  puts ""
  puts "🔑 بيانات الدخول:"
  puts "  البريد الإلكتروني: admin@example.com"
  puts "  كلمة المرور: changeme"
  puts ""
  puts "⚠️  تذكير: غيّر كلمة المرور فوراً بعد تسجيل الدخول الأول!"
end
