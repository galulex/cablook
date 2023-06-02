class Presenters::Trips::DetailedCollection < Presenters::BaseCollection
  collection :entries, extend: Presenters::Trips::Detailed, as: :trips

  property :settings, exec_context: :decorator

  def settings
    Presenters::Settings::DriverPublic.new(Settings)
  end
end
