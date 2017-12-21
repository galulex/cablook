module Presenters
  module Cards
    class Single < Presenters::BaseSingle
      properties :id, :token, :pan, :type, :currency
    end
  end
end
