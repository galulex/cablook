FactoryBot.define do
  factory :trip_job do
    activejob_id { Faker::Number.number(10) }
    sidekiq_id { Faker::Number.number(10) }
  end
end
