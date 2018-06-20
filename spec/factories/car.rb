FactoryBot.define do
  factory :car do
    number { Faker::Number.number(4).to_s }
    status 1
    color { Faker::Color.hex_color }
    phone_number { "+#{Faker::Number.number(12)}" }
  end
end
