require 'spec_helper'

describe NotificationMailer do
  describe '#issue_submitted_email' do
    let!(:repository) { create :repository, name: 'CoolCode', owner: 'CoolOrg', notification_emails: 'joe@email.com' }

    subject { NotificationMailer.issue_submitted_email(repository.id, 1) }

    it 'sends notification mail' do
      expect(subject.body).to have_content('New issue submitted to repository CoolCode!')
    end
  end
end
