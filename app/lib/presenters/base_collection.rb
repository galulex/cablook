require 'roar/decorator'
require 'roar/json'

class Presenters::BaseCollection < Roar::Decorator
  include Roar::JSON
end
