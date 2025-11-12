#!/bin/bash
# BlogBowl Testing Commands Reference
# Use these commands to verify fixes and run tests

set -e

echo "==========================================="
echo "BlogBowl Testing Commands"
echo "==========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_CONTAINER="blogbowl_app"
DB_CONTAINER="blogbowl-postgres-1"
REDIS_CONTAINER="blogbowl-redis-1"

# ============================================
# 1. INFRASTRUCTURE CHECKS
# ============================================

echo -e "${YELLOW}=== Infrastructure Health Checks ===${NC}"
echo ""

check_containers() {
    echo "Checking Docker containers..."
    docker ps --filter "label=com.docker.compose.project=blogbowl" --format "table {{.Names}}\t{{.Status}}"
    echo ""
}

check_app_health() {
    echo "Checking app health..."
    docker exec $APP_CONTAINER curl -s http://localhost:3000/pages > /dev/null && \
        echo -e "${GREEN}✓ App is responding${NC}" || \
        echo -e "${RED}✗ App is not responding${NC}"
    echo ""
}

check_database() {
    echo "Checking database connection..."
    docker exec $APP_CONTAINER bin/rails runner "puts 'Database connected: ' + ActiveRecord::Base.connection.database_version" && \
        echo -e "${GREEN}✓ Database is connected${NC}" || \
        echo -e "${RED}✗ Database connection failed${NC}"
    echo ""
}

check_redis() {
    echo "Checking Redis connection..."
    docker exec $REDIS_CONTAINER redis-cli ping > /dev/null 2>&1 && \
        echo -e "${GREEN}✓ Redis is running${NC}" || \
        echo -e "${RED}✗ Redis is not responding${NC}"
    echo ""
}

# ============================================
# 2. POST PUBLISHING TEST
# ============================================

test_post_publishing() {
    echo -e "${YELLOW}=== Post Publishing Test ===${NC}"
    echo "Testing post publishing workflow..."
    echo ""

    # Create a test post
    echo "1. Creating test post..."
    TEST_POST_ID=$(docker exec $APP_CONTAINER bin/rails runner "
      page = CoreEngine::Page.find_by(slug: 'my-blog')
      post = page.posts.create!(
        title: 'Publishing Test Post',
        status: :draft
      )
      puts post.id
    ")

    echo "   Created post with ID: $TEST_POST_ID"
    echo ""

    # Create a test author
    echo "2. Creating test author..."
    AUTHOR_ID=$(docker exec $APP_CONTAINER bin/rails runner "
      author = CoreEngine::Author.create!(
        first_name: 'Test',
        last_name: 'Author',
        user_id: 1
      )
      puts author.id
    ")

    echo "   Created author with ID: $AUTHOR_ID"
    echo ""

    # Assign author to post
    echo "3. Assigning author to post..."
    docker exec $APP_CONTAINER bin/rails runner "
      post = CoreEngine::Post.find($TEST_POST_ID)
      post.post_authors.create!(author_id: $AUTHOR_ID, role: 'author')
      puts 'Author assigned'
    "
    echo ""

    # Test publishing
    echo "4. Attempting to publish post..."
    PUBLISH_RESULT=$(docker exec $APP_CONTAINER bin/rails runner "
      post = CoreEngine::Post.find($TEST_POST_ID)
      begin
        post.publish!
        puts 'SUCCESS'
      rescue StandardError => e
        puts 'FAILED: ' + e.message
      end
    " 2>&1)

    if [[ "$PUBLISH_RESULT" == *"SUCCESS"* ]]; then
        echo -e "${GREEN}✓ Post published successfully${NC}"
    else
        echo -e "${RED}✗ Post publishing failed${NC}"
        echo "   Error: $PUBLISH_RESULT"
    fi
    echo ""
}

# ============================================
# 3. DATABASE QUERIES
# ============================================

query_posts() {
    echo -e "${YELLOW}=== Posts Database Query ===${NC}"
    docker exec $APP_CONTAINER bin/rails runner "
      puts 'Posts Summary:'
      CoreEngine::Post.select(:id, :title, :slug, :status).each do |post|
        puts \"  - ID: #{post.id}, Title: #{post.title}, Slug: #{post.slug}, Status: #{post.status}\"
      end
    "
    echo ""
}

query_authors() {
    echo -e "${YELLOW}=== Authors Database Query ===${NC}"
    docker exec $APP_CONTAINER bin/rails runner "
      puts 'Authors Summary:'
      CoreEngine::Author.all.each do |author|
        puts \"  - ID: #{author.id}, Name: #{author.first_name} #{author.last_name}\"
      end
    "
    echo ""
}

query_categories() {
    echo -e "${YELLOW}=== Categories Database Query ===${NC}"
    docker exec $APP_CONTAINER bin/rails runner "
      puts 'Categories Summary:'
      CoreEngine::Category.all.each do |cat|
        puts \"  - ID: #{cat.id}, Name: #{cat.name}, Slug: #{cat.slug}\"
      end
    "
    echo ""
}

# ============================================
# 4. CODE INSPECTION
# ============================================

find_svg_issues() {
    echo -e "${YELLOW}=== Searching for SVG viewBox Issues ===${NC}"
    echo "Searching for malformed SVG viewBox attributes..."
    echo ""

    ISSUES=$(find . -type f \( -name "*.jsx" -o -name "*.tsx" -o -name "*.rb" -o -name "*.erb" \) -exec grep -l "viewBox" {} \; 2>/dev/null | head -20)

    if [ -z "$ISSUES" ]; then
        echo "No SVG viewBox references found"
    else
        echo "Files with SVG viewBox:"
        echo "$ISSUES" | while read file; do
            echo "  - $file"
        done
    fi
    echo ""
}

find_duplicate_ids() {
    echo -e "${YELLOW}=== Searching for Duplicate Element IDs ===${NC}"
    echo "Searching for duplicate id attributes..."
    echo ""

    DUPLICATES=$(grep -r 'id="posts_role"' . --include="*.erb" --include="*.jbuilder" 2>/dev/null)

    if [ -z "$DUPLICATES" ]; then
        echo "No duplicate posts_role IDs found"
    else
        echo "Found duplicate IDs:"
        echo "$DUPLICATES" | while read line; do
            echo "  - $line"
        done
    fi
    echo ""
}

find_missing_autocomplete() {
    echo -e "${YELLOW}=== Searching for Missing Autocomplete Attributes ===${NC}"
    echo "Searching for input fields without autocomplete..."
    echo ""

    MISSING=$(grep -r '<input type="email"' submodules/core/app/views --include="*.erb" 2>/dev/null | grep -v 'autocomplete' | head -10)

    if [ -z "$MISSING" ]; then
        echo "All email inputs have autocomplete attributes"
    else
        echo "Found inputs without autocomplete:"
        echo "$MISSING"
    fi
    echo ""
}

# ============================================
# 5. LOG ANALYSIS
# ============================================

check_errors_in_logs() {
    echo -e "${YELLOW}=== Recent Errors in Docker Logs ===${NC}"
    echo "Last 20 error entries..."
    echo ""

    docker logs $APP_CONTAINER 2>&1 | grep -i "error\|failed\|invalid" | tail -20
    echo ""
}

# ============================================
# 6. RUN TESTS (if in test environment)
# ============================================

run_tests() {
    echo -e "${YELLOW}=== Running Test Suite ===${NC}"

    # Check if we can run tests
    RAILS_ENV=$(docker exec $APP_CONTAINER printenv RAILS_ENV)

    if [ "$RAILS_ENV" == "production" ]; then
        echo -e "${RED}✗ Cannot run tests in production mode${NC}"
        echo "Tests require RAILS_ENV=test"
        echo ""
        echo "To run tests, you would need to:"
        echo "1. Set RAILS_ENV=test in docker-compose.yaml"
        echo "2. Restart containers"
        echo "3. Run: docker exec $APP_CONTAINER bin/rails test"
    else
        echo "Running test suite..."
        docker exec $APP_CONTAINER bin/rails test
    fi
    echo ""
}

# ============================================
# 7. FIX VERIFICATION
# ============================================

verify_slug_fix() {
    echo -e "${YELLOW}=== Verifying Post Slug Fix ===${NC}"
    echo "Checking if slug generation works on publish..."
    echo ""

    docker exec $APP_CONTAINER bin/rails runner "
      # Create a post without a slug
      page = CoreEngine::Page.find_by(slug: 'my-blog')
      post = page.posts.create!(
        title: 'Slug Fix Test',
        status: :draft,
        slug: nil  # Force nil slug
      )
      puts \"Post created with slug: #{post.slug}\"

      # Create minimal revision
      revision = post.post_revisions.create!(
        kind: :draft,
        title: 'Slug Fix Test'
      )

      # Try to apply revision (this is what happens during publish)
      begin
        revision.apply!
        puts \"After apply! - Slug is: #{post.reload.slug}\"
      rescue StandardError => e
        puts \"Error during apply!: #{e.message}\"
      end
    "
    echo ""
}

# ============================================
# 8. MENU SYSTEM
# ============================================

show_menu() {
    echo "==========================================="
    echo "Available Commands:"
    echo "==========================================="
    echo ""
    echo "Infrastructure:"
    echo "  1) check_containers       - Check Docker container status"
    echo "  2) check_app_health       - Check if app is responding"
    echo "  3) check_database         - Check database connection"
    echo "  4) check_redis            - Check Redis connection"
    echo ""
    echo "Testing:"
    echo "  5) test_post_publishing   - Test post publishing workflow"
    echo "  6) verify_slug_fix        - Verify slug generation fix"
    echo ""
    echo "Data Inspection:"
    echo "  7) query_posts            - List all posts"
    echo "  8) query_authors          - List all authors"
    echo "  9) query_categories       - List all categories"
    echo ""
    echo "Code Analysis:"
    echo " 10) find_svg_issues        - Search for SVG viewBox problems"
    echo " 11) find_duplicate_ids     - Search for duplicate element IDs"
    echo " 12) find_missing_autocomplete - Find missing autocomplete attrs"
    echo ""
    echo "Debugging:"
    echo " 13) check_errors_in_logs   - Show recent errors in logs"
    echo " 14) run_tests              - Run test suite"
    echo ""
    echo "All:"
    echo " 15) run_all                - Run all checks and tests"
    echo ""
    echo " 0) exit                    - Exit menu"
    echo ""
}

run_all() {
    check_containers
    check_app_health
    check_database
    check_redis
    query_posts
    query_authors
    query_categories
    find_svg_issues
    find_duplicate_ids
    find_missing_autocomplete
    check_errors_in_logs
}

# ============================================
# MAIN MENU LOOP
# ============================================

if [ "$1" == "" ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Select command (0-15): " choice

        case $choice in
            1) check_containers ;;
            2) check_app_health ;;
            3) check_database ;;
            4) check_redis ;;
            5) test_post_publishing ;;
            6) verify_slug_fix ;;
            7) query_posts ;;
            8) query_authors ;;
            9) query_categories ;;
            10) find_svg_issues ;;
            11) find_duplicate_ids ;;
            12) find_missing_autocomplete ;;
            13) check_errors_in_logs ;;
            14) run_tests ;;
            15) run_all ;;
            0) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice. Please try again." ;;
        esac

        read -p "Press Enter to continue..."
    done
else
    # Command line mode - run specified function
    case $1 in
        containers) check_containers ;;
        health) check_app_health ;;
        db) check_database ;;
        redis) check_redis ;;
        test_publish) test_post_publishing ;;
        verify_slug) verify_slug_fix ;;
        posts) query_posts ;;
        authors) query_authors ;;
        categories) query_categories ;;
        svg) find_svg_issues ;;
        ids) find_duplicate_ids ;;
        autocomplete) find_missing_autocomplete ;;
        logs) check_errors_in_logs ;;
        tests) run_tests ;;
        all) run_all ;;
        *) echo "Unknown command: $1"; show_menu; exit 1 ;;
    esac
fi
