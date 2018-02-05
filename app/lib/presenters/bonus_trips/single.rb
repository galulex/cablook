module Presenters
  module BonusTrips
    class Single < Presenters::BaseSingle
      properties :id, :status, :user_id, :friend_id, :trip_id, :code
    end
  end
end
