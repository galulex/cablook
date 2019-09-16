module Constants
  module Sms
    URL = URI.parse('http://sms-fly.com/api/api.php').freeze
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

    ACCEPT = 'ACCEPT'.freeze
  end
end
