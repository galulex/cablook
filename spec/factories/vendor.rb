FactoryBot.define do
  factory :vendor do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    location { '49.441227,32.058585' }
    address { 'вул. Гоголя, 242/1' }
    url { "http://www.servant.ck.ua/" }
    api_url { "http://www.servant.ck.ua/wp-json/v1/menu" }
    logo_url { "https://instagram.fkbp1-1.fna.fbcdn.net/vp/727ad9ccec56f389aee843f97fea0742/5D91421F/t51.2885-19/s150x150/12556139_221126681567476_1636485382_a.jpg?_nc_ht=instagram.fkbp1-1.fna.fbcdn.net" }
    open_at { DateTime.new(2000, 1, 1, 11, 0, 0) }
    close_at { DateTime.new(2000, 1, 1, 23, 0, 0) }
    telegram_account { Random.rand(100000000..999999999) }
    need_approve { 'true' }
  end
end
