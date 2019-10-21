FactoryBot.define do
  factory :order do
    items { {"4506"=>"{\"quantity\"=>1, \"item_price\"=>\"39\", \"total_price\"=>39, \"item_name\"=>\"Телятина на живу з хоспера\", \"item_category\"=>\"М'ясні страви\"}"} }
    amount { 39 }
    association(:user)
    association(:vendor)
  end
end
