Factory.define(:payment) do |f|
  f.amount { fake(:number, :number, 2) }
  f.status { 0 }
end
