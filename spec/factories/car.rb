Factory.define(:car) do |f|
  f.number { fake(:number, :number, 4).to_s }
  f.status 1
  f.color { fake(:color, :hex_color) }
  f.phone_number { "+#{fake(:number, :number, 12)}" }
end
