module Events
  module Orders
    class Build < BaseEvent
      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

          required(:destination).filled
          required(:destination_address).filled(:str?)
          required(:vendor_id).filled
        end
      end

      def run
        validate_params!
        Events::Trips::Build.(trip_params)
      end

      private

      def trip_params
        data.slice(:destination, :destination_address).merge(vendor_address)
      end

      def vendor
        @vendor ||= Vendor.find(data[:vendor_id])
      end

      def vendor_address
        { departure: vendor.location, departure_address: vendor.address, osrm: true }
      end
    end
  end
end
