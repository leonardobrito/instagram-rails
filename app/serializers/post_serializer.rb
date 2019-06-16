class PostSerializer < ActiveModel::Serializer
  attributes :_id, :author, :place, :description, :hashtags, :image, :likes, :createdAt, :updatedAt
  has_many :comments
  
  def _id
    self.object.id
  end

  def image
    self.object.image_url
  end

  def createdAt
    self.object.created_at
  end

  def updatedAt
    self.object.updated_at
  end
end
