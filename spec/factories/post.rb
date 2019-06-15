include ActionDispatch::TestProcess
FactoryBot.define do
  factory :post do
    author { "some author" }
    place { "some place" }
    description { "some description" }
    hashtags { "#some_hashtags" }
    
    trait :other_post do
      author { "other author" }
      place { "other place" }
      description { "other description" }
      hashtags { "#other_hashtags" }
    end

    trait :with_image do
      after :create do |post_image|
        file_path = Rails.root.join('spec', 'support', 'assets', 'box-juice.png')
        file = fixture_file_upload(file_path, 'image/png')
        post_image.image.attach(file)
      end
    end
  
  end
end