describe Events::Cards::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { JSON.parse(File.read('spec/fixtures/fondy/create_callback.json')).symbolize_keys.merge(user_id: user.id) }
    let!(:user) { create(:user) }

    context 'when card is created successfully' do
      it { is_expected.to change { Card.count }.by(+1) }
    end

    context 'and user email is updated' do
      it { is_expected.to change { user.reload.email }.to(data[:sender_email]) }
    end

    context 'when user with data number not found' do
      let(:data) { super().merge(user_id: 9999) }

      it { is_expected.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'when token already exist' do
      let(:card) { create(:card, user_id: user.id,) }
      let(:data) { super().merge(rectoken: card.token) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when second type card' do
      let!(:data) do
        JSON.parse(File.read('spec/fixtures/fondy/second_create_callback.json'))
            .symbolize_keys
            .merge(user_id: user.id)
      end

      context 'when card is created successfully' do
        it { is_expected.to change { Card.count }.by(+1) }
      end
    end
  end
end
