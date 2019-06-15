include Rails.application.routes.url_helpers
class Post < ApplicationRecord
  has_one_attached :image
  validates :author, presence: true, uniqueness: true

  def image_url
    url_for(image)
  end

end
