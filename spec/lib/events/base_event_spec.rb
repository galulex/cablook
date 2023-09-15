describe Events::BaseEvent do
  let(:data) { { key: 'value' } }

  subject { described_class.new(data) }

  describe '#initialize' do
    it 'initializes with data' do
      expect(subject.data).to eq(data)
    end
  end

  describe '.call' do
    it 'creates a new instance and calls it' do
      instance_double = instance_double(described_class)
      expect(described_class).to receive(:new).with(data).and_return(instance_double)
      expect(instance_double).to receive(:call)
      described_class.call(data)
    end
  end

  describe '#call' do
    it 'validates parameters and runs #run' do
      expect(subject).to receive(:validate_params!)
      expect(subject).to receive(:run)
      subject.call
    end
  end

  describe '#run' do
    it 'raises NotImplementedError' do
      expect { subject.run }.to raise_error(NotImplementedError)
    end
  end
end
