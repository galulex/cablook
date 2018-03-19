module Presenters
  module BonusTrips
    class Single < Presenters::BaseSingle
      properties :id, :status, :user_id, :friend_id, :trip_id, :code, :type

      property :user, decorator: Presenters::Users::SinglePublic
      property :friend, decorator: Presenters::Users::SinglePublic
    end
  end
end
