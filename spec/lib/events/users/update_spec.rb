describe Events::Users::Update do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let!(:user) { create(:user) }
    let(:data) { { user_id: user.id, locale: 'en' } }

    it { is_expected.to change { user.reload.locale }.to('en') }

    context 'when locale is invalid' do
      let(:data) { super().merge(locale: 'invalid') }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
