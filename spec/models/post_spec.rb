require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:post) { create :post, :with_image }  
  let(:post_attributes_valid) { attributes_for :post, :with_image }  
  let(:post_attributes_invalid) { attributes_for :post, { author: '' } }  
  let(:image_name) { 'box-juice.png' }

  context "when create a post" do
    it "should be valid with valid attributes" do
      post = Post.create(post_attributes_valid)
      expect(post).to be_valid
    end

    it "should be not valid with invalid attributes" do
      post = Post.create(post_attributes_invalid)
      expect(post).to_not be_valid
    end

    it "should have attached image" do
      expect(post.image.attached?).to be_truthy
    end
  end

  context "when call image_url" do
    it "should contains default_url_options on image_url" do
      expect(post.image_url).to include(ENV['DEFAULT_URL_OPTIONS'])
    end
  
    it "should contains image_name on image_url" do
      post_image_name = post.image_url.split('/').last
      expect(post_image_name).to include(image_name)
    end
  end
end