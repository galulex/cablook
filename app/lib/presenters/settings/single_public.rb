class Presenters::Settings::SinglePublic < Presenters::BaseSingle
  property :sos, exec_context: :decorator
  property :overspeed_notify, exec_context: :decorator

  def sos
    settings.sos
  end

  def overspeed_notify
    settings.overspeed_notify
  end

  def settings
    @settings ||= Settings.get.feature
  end
end
