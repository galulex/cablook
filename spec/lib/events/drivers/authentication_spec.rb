describe Events::Drivers::Authentication do
  describe '.call' do
    let(:result) { described_class.call(data) }
    let!(:driver) { Factory[:driver] }
    let(:data) do
      {
        username: driver.username,
        password: '12341234'
      }
    end

    it { expect(result).not_to be nil }
    it { expect(result.username).to eq(driver.username) }

    context 'when data is invalid' do
      subject { -> { result } }

      let(:data) { { name: driver.name, password: Faker::Internet.password } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
