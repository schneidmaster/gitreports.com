shared_examples_for 'has unique users' do
  let(:model) { described_class }
  let(:user) { create :user }
  let(:repository) { create :repository, users: users }

  subject { repository.add_user! user }

  context 'users include user' do
    let(:users) { [user] }

    it 'does not add duplicate' do
      expect { subject }.not_to change { repository.users.count }.from(1)
    end
  end

  context 'users do not include user' do
    let(:users) { [] }

    it 'adds user' do
      expect { subject }.to change { repository.users.count }.from(0).to(1)
    end
  end
end
