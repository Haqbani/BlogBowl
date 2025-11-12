module PostsHelper
  def is_selected?(selected_value, item)
    if item.respond_to?(:slug)
      selected_value == item.slug
    else
      selected_value == item
    end
  end

  def sort_text(sort)
    {
      'newest' => t('common_phrases.newest_first'),
      'oldest' => t('common_phrases.oldest_first'),
      'title_asc' => t('common_phrases.title_asc'),
      'title_desc' => t('common_phrases.title_desc')
    }[sort] || t('common_phrases.newest_first')
  end
end
