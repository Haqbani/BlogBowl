ws = Workspace.first
page = ws.pages.build(workspace: ws, slug: 'blog', name: 'My blog')
puts "Generated domain: #{page.domain.inspect}"
puts "ENV PAGES_BASE_DOMAIN: #{ENV['PAGES_BASE_DOMAIN'].inspect}"
puts "Valid: #{page.valid?}"
puts "Errors: #{page.errors.full_messages.join(', ')}" unless page.valid?
