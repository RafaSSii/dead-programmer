class Article < ApplicationRecord
  STATUSES = %w[draft published].freeze
  CONTENT_FORMATS = %w[markdown visual].freeze
  before_validation :generate_slug, if: -> { slug.blank? && title.present? }
  before_validation :set_published_at, if: -> { status == "published" && published_at.nil? }

  validates :title, presence: true, length: { maximum: 180 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
  validates :excerpt, length: { maximum: 320 }, allow_blank: true
  validates :body, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :content_format, inclusion: { in: CONTENT_FORMATS }

  scope :published, -> { where(status: "published").where.not(published_at: nil) }
  scope :recent_first, -> { order(published_at: :desc, created_at: :desc) }

  def reading_minutes
    [ (body.to_s.split.size / 200.0).ceil, 1 ].max
  end

  private

  def generate_slug
    base = title.to_s.parameterize
    candidate = base
    suffix = 2
    while self.class.where(slug: candidate).where.not(id: id).exists?
      candidate = "#{base}-#{suffix}"
      suffix += 1
    end
    self.slug = candidate
  end

  def set_published_at
    self.published_at = Time.current
  end
end
