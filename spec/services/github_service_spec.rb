require 'spec_helper'

describe GithubService do
  describe '#create_or_update_user' do
    subject { GithubService.create_or_update_user(access_token) }
  end

  describe '#load_repositories' do

    subject { GithubService.load_repositories('access') }

    context 'first user login' do
      let!(:user) { GithubService.create_or_update_user('access') }

      before { subject }

      it 'retrieves and stores repositories' do
        expect(user.repositories.count).to eq(4)
      end

      it('adds user to org') do
        expect(user.organizations.first.name).to eq('neatorg')
      end
    end

    context 'org repos exist' do
      let!(:user) { create :user, access_token: 'access' }
      let!(:org) { create :organization, name: 'neatorg' }
      let!(:org_repo) { create :repository, name: 'OldOrgCode', organization: org, users: [user] }
      let!(:existing_org_repo) { create :repository, name: 'NeatOrgStuff', github_id: 5_705_826, organization: org, users: [user] }

      before do
        GithubService.create_or_update_user('access')
        subject
      end

      it 'removes outdated org repository' do
        expect(user.repositories.find_by_name('OldOrgCode')).to eq(nil)
      end

      it 'updates org repository with new information' do
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

      before { subject }

      it 'adds existing repository to user' do
        expect(user.repositories.find_by_name('PrettyProject')).not_to eq(nil)
      end

      it 'adds existing org repository to user' do
        expect(user.repositories.find_by_name('NeatOrgProject')).not_to eq(nil)
      end

      it 'updates user repository with new name' do
        expect(user.repositories.find_by_name('CoolCode')).not_to eq(nil)
      end

      it 'deletes outdated user repository' do
        expect(user.repositories.find_by_name('OldCode')).to eq(nil)
      end
    end

    context 'user is removed from a repo with another user on it' do
      let!(:user) { create :user, access_token: 'access' }
      let!(:another_user) { create :user }
      let!(:repository) { create :user_repository, name: 'SharedCode', users: [user, another_user] }

      before { subject }

      it 'removes the user from the repository' do
        expect(user.repositories.find_by_name('SharedCode')).to eq(nil)
      end

      it 'leaves the repository and other user intact' do
        expect(another_user.repositories.find_by_name('SharedCode')).not_to eq(nil)
      end
    end

    context 'user is removed from an org with another user in it' do
      let!(:org) { create :organization, name: 'CoolOrg' }
      let!(:user) { create :user, access_token: 'access', organizations: [org] }
      let!(:another_user) { create :user, organizations: [org] }
      let!(:repository) { create :user_repository, name: 'SharedOrgCode', organization: org, users: [user, another_user] }

      before { subject }

      it 'removes the user from the org' do
        expect(user.organizations.find_by_name('CoolOrg')).to eq(nil)
      end

      it 'leaves the other user in the org' do
        expect(another_user.organizations.find_by_name('CoolOrg')).not_to eq(nil)
      end

      it 'removes the user from the org repository' do
        expect(user.repositories.find_by_name('SharedOrgCode')).to eq(nil)
      end

      it 'leaves the org repository intact' do
        expect(org.repositories.find_by_name('SharedOrgCode')).not_to eq(nil)
      end

      it 'leaves the other user on the org repository' do
        expect(repository.users.find(another_user)).not_to eq(nil)
      end
    end
  end

  describe '#submit_issue' do
    let!(:user) { create :user }
    let!(:repository) { create :repository, users: [user] }

    subject { GithubService.submit_issue(repository.id, 'Bob', 'bob@email.com', "I'm having a problem with this.") }

    it 'create the issue' do
      issue = subject
      expect(issue['body']).to eq("I'm having a problem with this.")
    end
  end
end
