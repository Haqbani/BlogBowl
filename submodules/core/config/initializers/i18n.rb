# frozen_string_literal: true

# I18n Configuration for BlogBowl
# Configures internationalization support for Arabic and English locales

Rails.application.config.i18n.tap do |i18n|
  # Set Arabic as the default locale
  i18n.default_locale = :ar

  # Available locales: Arabic and English
  i18n.available_locales = [:ar, :en]

  # Enable fallback to default locale when translation is missing
  i18n.fallbacks = true

  # Load locale files from all subdirectories
  i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
end
