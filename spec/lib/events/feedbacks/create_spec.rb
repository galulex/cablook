describe Events::Feedbacks::Create do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) do
      Factory.structs[:feedback, user_id: user.id, trip_id: trip.id].to_h
    end
    let(:user) { Factory[:user] }
    let(:trip) { Factory[:trip] }

    it { is_expected.to change { feedback_repository.feedbacks.count }.by(+1) }

    context 'when rate is empty' do
      let(:data) { Factory.structs[:feedback].to_h.except(:rate) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when description is empty' do
      let(:data) { Factory.structs[:feedback].to_h.except(:description) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when trip_id is empty' do
      let(:data) { Factory.structs[:feedback].to_h.except(:trip_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when user_id is empty' do
      let(:data) { Factory.structs[:feedback].to_h.except(:user_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when rate is greater than 5' do
      let(:data) { Factory.structs[:feedback].to_h.merge(rate: 10) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
