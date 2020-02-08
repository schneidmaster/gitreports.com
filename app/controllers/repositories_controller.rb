class RepositoriesController < ApplicationController
  before_action :ensure_signed_in!, only: [:index]
  before_action :ensure_own_repository!, except: %i[index load_status repository submit submitted]

  def index
    @current_user = current_user
  end

  def show
    @repository = Repository.find(params[:id])
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def update
    @repository = Repository.find(params[:id])

    if @repository.update(repository_params)
      redirect_to repository_path(@repository)
    else
      render 'edit'
    end
  end

  def activate
    repo = Repository.find(params[:repository_id])
    repo.update(is_active: true)
    redirect_to repo
  end

  def deactivate
    repo = Repository.find(params[:repository_id])
    repo.update(is_active: false)
    redirect_to repo
  end

  def load_status
    render plain: Sidekiq::Status.complete?(session[:job_id])
  end

  private

  def repository_params
    params[:repository].permit(:display_name, :issue_name, :prompt, :followup, :labels, :allow_issue_title, :include_submitter_email).merge(
      notification_emails: parse_emails(params[:repository][:notification_emails]),
      allow_issue_title: (params[:repository][:allow_issue_title] == 'yes'),
      include_submitter_email: (params[:repository][:include_submitter_email] == 'yes')
    )
  end

  def current_resource
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])
    @current_resource ||= holder.repositories.find_by_name(params[:repositoryname])
  end

  def parse_emails(emails)
    valid_emails = []
    unless emails.nil?
      emails.split(/,|\n/).each do |full_email|
        next if full_email.blank?

        email = if full_email.index(/\<.+\>/)
                  full_email.match(/\<.*\>/)[0].gsub(/[\<\>]/, '').strip
                else
                  full_email.strip
                end
        email = email.delete('<').delete('>')
        valid_emails << email if ValidateEmail.valid?(email)
      end
    end
    valid_emails.join(', ')
  end
end
