require 'faker'
include ActionDispatch::TestProcess
FactoryBot.define do
  factory :post do
    author { Faker::Name.unique.name }
    place { Faker::Address.unique.city }
    description { Faker::Lorem.sentence }
    hashtags { Faker::Color.hex_color }

    trait :with_image do
      after :create do |post_image|
        file_path = Rails.root.join('spec', 'support', 'assets', 'box-juice.png')
        file = fixture_file_upload(file_path, 'image/png')
        post_image.image.attach(file)
      end
    end

    trait :with_comments do
      transient do
        comments_count { 5 }
      end

      after(:create) do |post, evaluator|
        create_list(:comment, evaluator.comments_count, post: post)
      end
    end
  end
end