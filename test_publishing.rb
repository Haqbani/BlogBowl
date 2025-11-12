ws = Workspace.first
page = ws.pages.first

# Create a post if it doesn't exist
post = page.posts.first
unless post
  category = page.categories.first || page.categories.create!(name: 'Test', slug: 'test', color: '#000000')
  author = page.authors.first

  post = page.posts.create!(
    title: 'Test Post',
    content_html: '<p>Test content</p>',
    content_json: {},
    status: 0,
    slug: 'test-post',
    description: 'Test description',
    category_id: category.id
  )

  if author
    post.post_authors.create!(author_id: author.id)
  end
end

# Create a revision
revision = post.post_revisions.create!(
  title: 'Updated Test Post',
  content_html: '<p>Updated content</p>',
  content_json: {},
  kind: 0
)

puts "Post slug before: #{post.slug}"
puts "Post status before: #{post.status}"
puts "Attempting to publish..."

begin
  post.publish!
  puts "SUCCESS: Post published!"
  post.reload
  puts "Post slug after: #{post.slug}"
  puts "Post status after: #{post.status}"
rescue => e
  puts "ERROR: #{e.message}"
  puts "Error class: #{e.class}"
  puts e.backtrace.first(5).join("\n")
end
