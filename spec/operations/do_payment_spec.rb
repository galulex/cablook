describe Operations::DoPayment do
  describe '.call' do
    let(:instance) { described_class.new(*params) }
    let(:params) { [1, 'Payments::Trip', 50] }
    let(:wayforpay_dopayment_class) { Operations::Wayforpay::DoPayment }
    let(:fondy_dopayment_class) { Operations::Fondy::DoPayment }

    describe '#call' do
      before do
        allow(wayforpay_dopayment_class).to receive(:new).with(*params).and_call_original
        allow(fondy_dopayment_class).to receive(:new).with(*params).and_call_original
        allow_any_instance_of(wayforpay_dopayment_class).to receive(:call).and_return({})
        allow_any_instance_of(fondy_dopayment_class).to receive(:call).and_return({})
      end

      after { instance.call }

      context 'when Wayforpay selected' do
        before { Settings.get.update!(payment_system: :wayforpay) }

        it { expect(wayforpay_dopayment_class).to receive(:new).with(*params).once }
        it { expect_any_instance_of(wayforpay_dopayment_class).to receive(:call).once }
      end

      context 'when Fondy selected' do
        before { Settings.get.update!(payment_system: :fondy) }

        it { expect(fondy_dopayment_class).to receive(:new).with(*params).once }
        it { expect_any_instance_of(fondy_dopayment_class).to receive(:call).once }
      end
    end
  end
end
