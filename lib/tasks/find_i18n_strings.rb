#!/usr/bin/env ruby
# Script to find hardcoded English strings in ERB templates for i18n translation
# Usage: ruby lib/tasks/find_i18n_strings.rb

require 'find'
require 'fileutils'

class I18nStringFinder
  VIEWS_PATH = 'submodules/core/app/views'

  # Common patterns for hardcoded English strings
  PATTERNS = [
    /"([A-Z][a-z]+[^"]*)"/, # Strings in double quotes starting with capital
    /'([A-Z][a-z]+[^']*)'/, # Strings in single quotes starting with capital
    />([\s]*[A-Z][a-z]+[^<]+)</ # Text between HTML tags
  ]

  # Directories to prioritize
  PRIORITY_DIRS = %w[
    sessions
    registrations
    passwords
    workspaces
    pages/posts
    pages/categories
    pages/settings
    settings
    members
    newsletters
    shared
    layouts
  ]

  attr_reader :results

  def initialize
    @results = Hash.new { |h, k| h[k] = [] }
    @file_count = 0
    @string_count = 0
  end

  def scan_files
    puts "🔍 Scanning view templates for hardcoded English strings...\n\n"

    PRIORITY_DIRS.each do |dir|
      scan_directory(File.join(VIEWS_PATH, dir))
    end

    generate_report
  end

  private

  def scan_directory(path)
    return unless File.directory?(path)

    Find.find(path) do |file|
      next unless file.end_with?('.erb')
      scan_file(file)
    end
  end

  def scan_file(filepath)
    return unless File.file?(filepath)

    content = File.read(filepath)
    relative_path = filepath.sub("#{VIEWS_PATH}/", '')

    found_strings = extract_strings(content)

    if found_strings.any?
      @results[relative_path] = found_strings
      @file_count += 1
      @string_count += found_strings.length
    end
  end

  def extract_strings(content)
    strings = []

    # Find content_for :title
    content.scan(/content_for :title,\s*["']([^"']+)["']/) do |match|
      strings << { type: :page_title, text: match[0], line: $`.count("\n") + 1 }
    end

    # Find form labels
    content.scan(/\.label\s+:\w+,\s*["']([^"']+)["']/) do |match|
      strings << { type: :form_label, text: match[0], line: $`.count("\n") + 1 }
    end

    # Find submit buttons
    content.scan(/\.submit\s+["']([^"']+)["']/) do |match|
      strings << { type: :button, text: match[0], line: $`.count("\n") + 1 }
    end

    # Find link_to text
    content.scan(/link_to\s+["']([^"']+)["']/) do |match|
      strings << { type: :link, text: match[0], line: $`.count("\n") + 1 }
    end

    # Find button_to text
    content.scan(/button_to\s+["']([^"']+)["']/) do |match|
      strings << { type: :button, text: match[0], line: $`.count("\n") + 1 }
    end

    # Find placeholder text
    content.scan(/placeholder:\s*["']([^"']+)["']/) do |match|
      strings << { type: :placeholder, text: match[0], line: $`.count("\n") + 1 }
    end

    # Find HTML headings
    content.scan(/<h[1-6][^>]*>([^<]+)<\/h[1-6]>/) do |match|
      text = match[0].strip
      next if text.start_with?('<%') || text.length < 3
      strings << { type: :heading, text: text, line: $`.count("\n") + 1 }
    end

    # Find span/div text content
    content.scan(/<(?:span|div|p)[^>]*>([A-Z][^<]{3,50})<\/(?:span|div|p)>/) do |match|
      text = match[0].strip
      next if text.start_with?('<%') || text.include?('<%=')
      strings << { type: :text, text: text, line: $`.count("\n") + 1 }
    end

    strings.uniq { |s| s[:text] }
  end

  def generate_report
    puts "\n📊 I18n Translation Scan Report"
    puts "=" * 80
    puts "Files scanned: #{@file_count}"
    puts "Strings found: #{@string_count}"
    puts "=" * 80
    puts "\n"

    # Group by priority
    priority_files = @results.select { |path, _| PRIORITY_DIRS.any? { |dir| path.start_with?(dir) } }

    puts "🔥 HIGH PRIORITY FILES (#{priority_files.count}):\n\n"

    priority_files.sort_by { |path, _| path }.each do |filepath, strings|
      puts "📄 #{filepath}"
      puts "   Strings to translate: #{strings.length}"

      strings.first(5).each do |str|
        puts "   - [#{str[:type]}] Line #{str[:line]}: \"#{str[:text]}\""
      end

      if strings.length > 5
        puts "   ... and #{strings.length - 5} more"
      end

      puts "\n"
    end

    # Save detailed report to file
    save_detailed_report

    puts "\n✅ Full detailed report saved to: tmp/i18n_translation_report.txt"
    puts "📝 Use this report to systematically translate all strings."
  end

  def save_detailed_report
    FileUtils.mkdir_p('tmp')

    File.open('tmp/i18n_translation_report.txt', 'w') do |f|
      f.puts "I18N TRANSLATION REPORT"
      f.puts "Generated: #{Time.now}"
      f.puts "=" * 100
      f.puts "\nSUMMARY:"
      f.puts "Files with hardcoded strings: #{@file_count}"
      f.puts "Total strings to translate: #{@string_count}"
      f.puts "\n" + "=" * 100
      f.puts "\nDETAILED BREAKDOWN:\n\n"

      @results.sort_by { |path, _| path }.each do |filepath, strings|
        f.puts "\n" + "─" * 100
        f.puts "FILE: #{filepath}"
        f.puts "COUNT: #{strings.length} strings"
        f.puts "─" * 100

        strings.each do |str|
          f.puts "\n[#{str[:type].to_s.upcase}] Line #{str[:line]}"
          f.puts "Original: \"#{str[:text]}\""
          f.puts "Suggested key: #{suggest_translation_key(str[:text], str[:type])}"
          f.puts ""
        end
      end
    end
  end

  def suggest_translation_key(text, type)
    # Generate suggested i18n key based on text
    base_key = text.downcase
                   .gsub(/[^\w\s]/, '')
                   .gsub(/\s+/, '_')
                   .slice(0, 40)

    case type
    when :page_title
      "pages.#{base_key}"
    when :button
      "buttons.#{base_key}"
    when :form_label
      "forms.#{base_key}"
    when :link
      "links.#{base_key}"
    else
      "common.#{base_key}"
    end
  end
end

# Run the scanner
if __FILE__ == $0
  finder = I18nStringFinder.new
  finder.scan_files
end
