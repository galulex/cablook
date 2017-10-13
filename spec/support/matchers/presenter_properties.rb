RSpec::Matchers.define :have_key do |key|
  chain :with_value do |value|
    @with_value = true
    @value = value.to_json
  end

  match do |json|
    expected = "\"#{key}\":"
    expected << @value if @with_value

    expect(json).to include expected
  end
end
