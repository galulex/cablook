describe Events::Cars::Update do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { { id: car.id, color: color } }
    let!(:car) { create(:car) }
    let(:color) { Faker::Color.hex_color }

    it { is_expected.to change { car.reload.color }.to(color) }
    it { is_expected.not_to change { car.reload.number } }

    context 'when invalid attributes' do
      let(:data) { { id: car.id, color: 1234 } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
