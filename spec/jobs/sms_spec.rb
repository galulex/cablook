describe Jobs::Sms do
  let(:body) do
    '<?xml version="1.0" encoding="utf-8"?>
    <message>
      <state code="%s" date="2012-01-24 12:48:32">%s</state>
    </message>'
  end

  subject { -> { described_class.new.perform('+380661234567', 'test') } }

  before do
    stub_request(:any, 'http://svitsms.com/api/api.php')
      .to_return(body: format(body, code, text), status: 200,
                 headers: { 'Content-Length' => 3 })
  end

  after { subject }

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
