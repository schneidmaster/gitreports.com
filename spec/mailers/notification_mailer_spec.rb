describe NotificationMailer do
  describe '#issue_submitted_email' do
    let!(:repository) { create :repository, name: 'CoolCode', owner: 'CoolOrg', notification_emails: 'joe@email.com' }

    subject { NotificationMailer.issue_submitted_email(repository.id, 1) }

    it 'sends notification mail' do
      expect(subject.body).to have_content('New issue submitted to repository CoolCode!')
    end

    let!(:repository) { create :repository, name: 'CoolCode', owner: 'CoolOrg', notification_emails: 'joe@email.com', include_submitter_email: true }

    subject { NotificationMailer.issue_submitted_email(repository.id, 1, submitter_name: 'Scott', submitter_email: 'Scott@Scott.com') }

    it 'sends notification mail with submitter information in subject' do
      expect(subject).to have_content('Subject: New Issue Submitted to CoolCode by Scott: Scott@Scott.com')
    end
  end
end
