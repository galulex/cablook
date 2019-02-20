describe Jobs::Sms do
  let(:xml_body) do
    '<?xml version="1.0" encoding="utf-8"?>
    <message>
      <state code="%s" date="2012-01-24 12:48:32">%s</state>
    </message>'
  end

  subject { -> { described_class.new.perform('+380661234567', 'test') } }

  before do
    stub_request(:any, Constants::Sms::URL.to_s)
      .to_return(body: body, status: 200, headers: { 'Content-Length' => 3 })
  end

  context 'when xml response received' do
    let(:body) { format(xml_body, code, text) }

    context 'when sms is sent' do
      let(:code) { 'ACCEPT' }
      let(:text) { 'success' }

      it { is_expected.to_not raise_error }
    end

    context 'when sms is not sent' do
      let(:code) { 'INSUFFICIENTFUNDS' }
      let(:text) { 'error' }

      it { is_expected.to raise_error(text) }
    end
  end

  context 'when xml response is not received' do
    let(:body) { 'error' }

    it { is_expected.to raise_error(body) }
  end
end
