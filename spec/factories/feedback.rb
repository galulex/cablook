Factory.define(:feedback) do |f|
  f.rate { fake(:number, :between, 1, 5) }
  f.description{ fake(:lorem, :sentence) }
end
