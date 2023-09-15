FactoryBot.define do
  factory :car do
    number { Faker::Number.number(digits: 4).to_s }
    status { 0 }
    color { Faker::Color.hex_color }
    brand { 'Tesla' }
    model { 'Model S' }
    phone_number { '0987654321' }
  end
end
