task schedule_daily_trip_suggestions: :environment do
  start_of_day = DateTime.now.beginning_of_day
  users = User.joins(:trips).where('trips.started_at > ?', DateTime.now - 7.days)
  users.each do |user|
    trips_suggestions = TripsSuggestionsGenerator.new(user, start_of_day)
    trips_suggestions.each do |trip_suggestion|
      SendTripSuggestionJob.perform_at(trip_suggestion[:push_notification_timestamp], trip_suggestion)
    end
  end
end