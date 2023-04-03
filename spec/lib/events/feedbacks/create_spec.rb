describe Events::Feedbacks::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { attributes_for(:feedback, user_id: user.id, trip_id: trip.id) }
    let(:user) { create(:user) }
    let(:trip) { create(:trip, user_id: user.id) }

    it { is_expected.to change { Feedback.count }.by(+1) }
    it { is_expected.not_to have_enqueued_job(Jobs::PaymentSettle) }

    context 'when rate is empty' do
      let(:data) { attributes_for(:feedback).except(:rate) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when description is empty' do
      let(:data) { attributes_for(:feedback).except(:description) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when trip_id is empty' do
      let(:data) { attributes_for(:feedback).except(:trip_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user_id is empty' do
      let(:data) { attributes_for(:feedback).except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when rate is greater than 5' do
      let(:data) { attributes_for(:feedback).merge(rate: 10) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when tip will be created' do
      let(:data) { super().merge(tip: amount) }
      let(:amount) { 10 }
      let!(:trip_payment) { create(:trip_payment, trip_id: trip.id, user_id: user.id, order_reference: 'order_reference') }

      before { user.cards.create(attributes_for(:card, user_id: user.id)) }

      it { is_expected.to have_enqueued_job(Jobs::PaymentSettle).with(trip.id, Constants::Payments::TYPES[:tip], amount) }
    end
  end
end
