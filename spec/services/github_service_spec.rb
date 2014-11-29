require 'spec_helper'

describe GithubService do
  describe '#create_or_update_user' do
    subject { GithubService.create_or_update_user(access_token) }
  end

  describe '#load_repositories' do

    subject { GithubService.load_repositories('access') }

    context 'first user login' do
      it 'retrieves and stores repositories, adds user to org' do
        GithubService.create_or_update_user('access')

        subject

        user = User.last

        expect(user.repositories.count).to eq(4)
        expect(user.organizations.first.name).to eq('neatorg')
      end
    end

    context 'org repos exist' do
      let!(:user) { create :user, access_token: 'access' }
      let!(:org) { create :organization, name: 'neatorg' }
      let!(:org_repo) { create :repository, name: 'OldOrgCode', organization: org, users: [user] }
      let!(:existing_org_repo) { create :repository, name: 'NeatOrgStuff', github_id: 5_705_826, organization: org, users: [user] }

      it 'updates org repos' do
        GithubService.create_or_update_user('access')
        
        subject

        expect(user.repositories.find_by_name('OldOrgCode')).to eq(nil)
        expect(user.repositories.find_by_name('NeatOrgCode')).not_to eq(nil)
      end
    end

    context 'user repos exist' do
      let!(:org) { create :organization }
      let!(:user) { create :user, access_token: 'access', organizations: [org] }
      let!(:repository) { create :user_repository, name: 'OldCode', users: [user] }
      let!(:existing_repo) { create :user_repository, name: 'NeatCode', github_id: 5_705_827, users: [user] }
      let!(:unlinked_repo) { create :user_repository, name: 'PrettyProject', github_id: 19_548_054 }
      let!(:unlinked_org_repo) { create :repository, name: 'NeatOrgProject', github_id: 19_548_055 }

      it 'updates repos' do
        subject

        expect(user.repositories.find_by_name('PrettyProject')).not_to eq(nil)
        expect(user.repositories.find_by_name('NeatOrgProject')).not_to eq(nil)
        expect(user.repositories.find_by_name('CoolCode')).not_to eq(nil)
        expect(user.repositories.find_by_name('OldCode')).to eq(nil)
      end
    end
  end
end