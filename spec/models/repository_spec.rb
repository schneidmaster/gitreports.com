require 'spec_helper'

describe Repository do
  describe '#holder_name' do
    context 'owner field is set' do
      subject { create :repository, owner: 'greptest' }

      it 'returns owner field' do
        expect(subject.holder_name).to eq('greptest')
      end
    end

    context 'repository is in an organization' do
      let!(:organization) { create :organization, name: 'CoolOrg' }

      subject { create :repository, owner: nil, organization: organization }

      it 'returns organization name' do
        expect(subject.holder_name).to eq('CoolOrg')
      end
    end

    context 'repository is a user repository' do
      let!(:user) { create :user, username: 'joeschmoe' }

      subject { create :user_repository, owner: nil, users: [user] }

      it 'returns user\'s username' do
        expect(subject.holder_name).to eq('joeschmoe')
      end
    end
  end
end
