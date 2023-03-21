module Fondy
  class Base
    CURRENCY = 'UAH'.freeze
    YES = 'Y'.freeze
    CARD = 'card'.freeze  

    private

    def merchant_id
      ENV['FONDY_MERCHANT_ID'].to_s
    end
  
    def pass
      ENV['FONDY_MERCHANT_PASS']
    end
  
    def signature(params)
      sha = Digest::SHA1.new
      sha.update("#{pass}|#{params.compact.sort.to_h.values.join('|')}")
      { signature: sha.hexdigest }
    end
  
    def header 
      { 'Content-Type' => 'application/json' }
    end
  end
end