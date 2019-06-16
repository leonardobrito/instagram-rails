include Rails.application.routes.url_helpers
class Post < ApplicationRecord
  has_one_attached :image
  has_many :comments
  validates :author, presence: true, uniqueness: true
  # scope :confirmed, -> { where.not(confirmed_at: nil) }

  def image_url
    url_for(image)
  end

end
