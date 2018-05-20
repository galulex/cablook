require 'spec_helper'

RSpec.describe Business, type: :model do
  describe '#employee=' do
    let!(:user) { User.create(phone_number: '+380932225665') }
    let!(:employee) { User.create(phone_number: '+380502225665') }
    let(:new_phone) { '+380672225665' }

    it 'assigns user to business' do
      expect { subject.employees = [employee.phone_number] }.to change { subject.users.size }.by(1)
    end

    it 'does not create new user' do
      expect { subject.employees = [employee.phone_number] }.not_to change { User.count }
    end

    it 'creates new user' do
      expect { subject.employees = [new_phone] }.to change { User.count }.by(1)
    end
  end
end
