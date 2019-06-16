require 'faker'
include ActionDispatch::TestProcess
FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.sentence }
    association :post, :with_image
    
    trait :other_comment do
      content { Faker::Lorem.sentence }
    end
  end
end
