describe Events::Users::Authorize do
  describe '.call' do
    subject { -> { result } }

    let(:result) { described_class.call(data) }
    let!(:user) { create(:user) }
    let(:data) { { phone_number: user[:phone_number], locale: 'en' } }

    it { expect(result).not_to be nil }
    it { expect(result.phone_number).to eq(user.phone_number) }
    it { expect(result.locale).to eq(user.locale) }

    context 'when phone_number is invalid' do
      let(:data) { { phone_number: Faker::Number.number(digits: 12).to_s } }

      it { is_expected.to raise_error(::Events::InvalidParamsError) }
    end

    context 'when user will create' do
      let!(:user) { attributes_for(:user) }

      it { is_expected.to change { User.count }.by(+1) }
    end
  end
end
