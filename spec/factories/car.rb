Factory.define(:car) do |f|
  f.number { fake(:number, :number, 4).to_s }
  f.status { fake(:number, :between, 0, 1) }
end
