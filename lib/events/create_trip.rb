module Events
  class CreateTrip < BaseEvent
    def schema
      Dry::Validation.Schema do
        configure { config.messages = :i18n }

        required(:path).filled(:str?)
        required(:cost).filled(:float?)
        required(:user_id).filled(:int?)

        required(:departure) { array? & size?(2) }
        required(:destination) { array? & size?(2) }
        required(:departure_address).filled(:str?)
        required(:destination_address).filled(:str?)

        optional(:card_id).filled(:int?)
      end
    end

    def run
      convert_location_to_pg_array
      validate!
      trip = create_trip
      job = Jobs::SearchCarForTrip.perform_later(trip.id)
      create_trip_job(job, trip.id)
      create_trip_payment(trip.id)
      trip
    end

    private

    def validate!
      validator = Validators::Trip.new(data)
      invalid!(validator.errors.values.flatten) if validator.invalid?
    end

    def create_trip
      Repositories::Trip.new(ROM.env).create(data.to_h)
    end

    def create_trip_job(job, trip_id)
      Repositories::TripJob.new(ROM.env).create(
        activejob_id: job.job_id,
        sidekiq_id: job.provider_job_id,
        trip_id: trip_id
      )
    end

    def convert_location_to_pg_array
      data[:departure] = Sequel.pg_array(data[:departure])
      data[:destination] = Sequel.pg_array(data[:destination])
    end

    def create_trip_payment(trip_id)
      Repositories::Payment.new(ROM.env).create(
        amount: data[:cost],
        card_id: data[:card_id],
        trip_id: trip_id
      )
      # TODO: WayForPayAPI.call
    end
  end
end
