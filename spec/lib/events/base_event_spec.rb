describe Events::BaseEvent do
  describe '.call' do
    subject { -> { described_class.new.call } }

    it { is_expected.to raise_error(NotImplementedError) }
  end
end
