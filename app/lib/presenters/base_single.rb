require 'roar/decorator'
require 'roar/json'

class Presenters::BaseSingle < Roar::Decorator
  include Roar::JSON

  class << self
    def properties(*props)
      props.each { |prop| property prop }
    end
  end
end
