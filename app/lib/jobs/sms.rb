module Jobs
  class Sms < ActiveJob::Base
    def perform(number, body)
      response = Net::HTTP.new(Constants::Sms::URL.host, Constants::Sms::URL.port).start do |http|
        http.request http_request(number, body)
      end
      raise response_state(response).text unless response_state(response)['code'] == Constants::Sms::ACCEPT
    end

    private

    def http_request(number, body)
      request = Net::HTTP::Post.new(Constants::Sms::URL.path)
      request.body = format(Constants::Sms::BODY, body, number)
      request.basic_auth(ENV['SVITSMS_USER'], ENV['SVITSMS_PASSWORD'])
      request.content_type = 'text/xml'
      request
    end

    def response_state(response)
      xml = Nokogiri::XML(response.read_body).at('//state')
      raise response.read_body unless xml
      xml.at('//state')
    end
  end
end
