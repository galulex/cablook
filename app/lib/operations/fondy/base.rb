module Operations
  module Fondy
    class Base

      private

      def settings
        @settings ||= Settings.get
      end
    end
  end
end
