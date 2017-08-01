class NotificationMailer < ActionMailer::Base
  default from: 'no-reply@gitreports.com'

  def issue_submitted_email(repo_id, issue_id, submitter_info = {})
    @repository = Repository.find(repo_id)
    @issue_id = issue_id

    @subject = "New Issue Submitted to #{@repository.name}"

    if submitter_info[:submitter_name].present? && submitter_info[:submitter_email].present?
      @subject = "#{@subject} by #{submitter_info[:submitter_name]}: #{submitter_info[:submitter_email]}"
    end

    mail to: @repository.notification_emails, subject: @subject
  end
end
