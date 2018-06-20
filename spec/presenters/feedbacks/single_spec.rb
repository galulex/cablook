describe Presenters::Feedbacks::Single do
  let(:user) { create(:user) }
  let(:trip) { create(:trip) }
  let(:feedback) { create(:feedback, trip_id: trip.id, user_id: user.id) }

  subject { described_class.new(feedback).to_json }

  it { is_expected.to have_key(:id).with_value(feedback.id) }
  it { is_expected.to have_key(:rate).with_value(feedback.rate) }
  it { is_expected.to have_key(:description).with_value(feedback.description) }
  it { is_expected.to have_key(:trip_id).with_value(feedback.trip_id) }
  it { is_expected.to have_key(:user_id).with_value(feedback.user_id) }
end
