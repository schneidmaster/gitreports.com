class NotificationMailer < ActionMailer::Base
  default from: 'no-reply@gitreports.com'

  def issue_submitted_email(repo_id, issue_id)
    @repository = Repository.find(repo_id)
    @issue_id = issue_id

    mail to: @repository.notification_emails, subject: "New Issue Submitted to #{@repository.name}"
  end
end
