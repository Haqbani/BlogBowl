module Models::PostRevisionConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :post

    enum :kind, { draft: 0, history: 1 }

    scope :drafts, -> { where(kind: :draft) }
    scope :history, -> { where(kind: :history) }
  end

  def apply!
    post.assign_attributes(title:, content_html:, content_json:, seo_title:, seo_description:, og_title:, og_description:)
    # Regenerate slug if the title has changed and slug is blank to ensure validation passes
    post.generate_slug if post.title_changed? && post.slug.blank?
    post.save!
  end

  def equals?(revision)
    except = [:id, :post_id, :kind, :created_at, :updated_at]
    self.attributes.symbolize_keys.except(*except) == revision.attributes.symbolize_keys.except(*except)
  end

  def share
    update(share_id: SecureRandom.uuid, shared_at: Time.current)
  end

end
