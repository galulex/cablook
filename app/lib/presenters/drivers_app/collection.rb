class Presenters::DriversApp::Collection < Presenters::BaseCollection
  collection :entries, extend: Presenters::DriversApp::SinglePublic, as: :drivers
end
