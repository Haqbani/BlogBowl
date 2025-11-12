ws = Workspace.first
page = ws.pages.build(workspace: ws, slug: 'blog', name: 'My blog')
puts "Valid: #{page.valid?}"
unless page.valid?
  puts "Errors: #{page.errors.full_messages.join(', ')}"
end
page.save
puts "Saved: #{page.persisted?}"
puts "Page ID: #{page.id}" if page.persisted?
