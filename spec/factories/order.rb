FactoryBot.define do
  factory :order do
    items { {"Гарніри, Картопля фрі"=>"{\"quantity\"=>1, \"item_price\"=>\"39\", \"total_price\"=>39}"} }
    amount { 39 }
    association(:user)
    association(:vendor)
  end
end

