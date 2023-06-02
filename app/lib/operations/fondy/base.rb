module Operations
  module Fondy
    class Base

      private

      def settings
        @settings ||= Settings.get.feature
      end
    end
  end
end
