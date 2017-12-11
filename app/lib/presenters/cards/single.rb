module Presenters
  module Cards
    class Single < Presenters::BaseSingle
      properties :id, :token, :pan, :type
    end
  end
end
