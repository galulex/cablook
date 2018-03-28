module Jobs
  class Sms < ActiveJob::Base
    URL = URI.parse('http://svitsms.com/api/api.php').freeze
    BODY = '
      <?xml version="1.0" encoding="utf-8"?>
      <request>
        <operation>SENDSMS</operation>
        <message start_time="AUTO" end_time="AUTO" lifetime="4" rate="120" desc="" source="CabLook">
          <body>%s</body>
          <recipient>%s</recipient>
        </message>
      </request>
    '.freeze

    def perform(number, body)
      request = Net::HTTP::Post.new(URL.path)
      request.body = format(BODY, body, number)
      p request.body
      request.basic_auth('+380636086045', 'SexMC90')
      request.content_type = 'text/xml'
      response = Net::HTTP.new(URL.host, URL.port).start { |http| http.request request }
      response
    end
  end
end
