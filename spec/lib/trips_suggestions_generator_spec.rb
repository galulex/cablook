RSpec.describe TripsSuggestionsGenerator do
  let(:user) { create :user }
  let(:date) { (DateTime.now - 3.days) }
  let!(:trip) { create :trip, user: user, status: Constants::Trip::FINISHED }
  let(:generator_instance) { described_class.new(user, date) }

  describe '#available_suggestions' do
    
  end

  describe '#user_trips_for' do
    let(:expected_suggestion_object) { generator_instance.new_suggestion_object trip }

    subject { generator_instance.user_trips_for(date - 7.days) }

    it 'include user trips happend on specified day' do
      is_expected.to include expected_suggestion_object
    end

    it 'include only user trips' do
    end

    it 'include only finished trips' do
    end

    it 'display only specified day trips' do
    end
  end

  describe '#new_suggestion_object' do
    subject { generator_instance.new_suggestion_object trip }

    it do
      expect{ subject[:push_notification_timestamp] }.not_to be_nil
      expect{ subject[:start_at] }.not_to be_nil
      expect{ subject[:departure_address] }.not_to be_nil
      expect{ subject[:destination_address] }.not_to be_nil
    end

    it 'set objective push notification timestamp' do
      expected_timestamp = DateTime.now
      expect { subject[:push_notification_timestamp] }.to eq expected_timestamp
    end

    it 'uses hours and minutes of previous trip' do
      expect { subject[:start_at].hour }.to eq date.hour
      expect { subject[:start_at].minute }.to eq date.minute
      expect { subject[:start_at].second }.to eq 0
    end

    it 'uses same addresses' do
      expect { subject[:departure_address] }.to eq trip.departure_address
      expect { subject[:destination_address] }.to eq trip.destination_address
    end
  end
end