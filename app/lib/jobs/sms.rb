module Jobs
  class Sms < ActiveJob::Base
    def perform(number, code)
      Twilio::REST::Client.new.api.account.messages.create(
        from: 'cablook',
        to: number,
        body: body
      )
    end
  end
end
