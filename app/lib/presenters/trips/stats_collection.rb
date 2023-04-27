class Presenters::Trips::StatsCollection < Presenters::BaseSingle
  collection :entries, extend: Presenters::Trips::StatsSingle, as: :trips
end
