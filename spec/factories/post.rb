include ActionDispatch::TestProcess
FactoryBot.define do
  factory :post do
    author { "some author" }
    place { "some place" }
    description { "some description" }
    hashtags { "#some_hashtags" }
    trait :with_image do
      after :create do |image|
        file_path = Rails.root.join('spec', 'support', 'assets', 'box-juice.png')
        file = fixture_file_upload(file_path, 'image/png')
        image.image.attach(file)
      end
    end
  end
end