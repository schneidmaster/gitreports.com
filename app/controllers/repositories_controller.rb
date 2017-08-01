class RepositoriesController < ApplicationController
  before_action :ensure_signed_in!, only: [:index]
  before_action :ensure_own_repository!, except: %i[index load_status repository submit submitted]
  before_action :ensure_repository_active!, only: %i[repository submit submitted]

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

  def repository
    @repository = current_resource

    # Set each param passed in the URL.
    %w[name email email_public issue_title details].each do |p|
      instance_variable_set("@#{p}", params[p.intern])
    end
  end

  def submit
    repo = current_resource

    # Check the captcha
    if pass_captcha?

      # Submit issue
      GithubJob.perform_later('submit_issue', repo.id, params[:name], params[:email], params[:email_public], params[:issue_title], params[:details])

      # Redirect
      redirect_to submitted_path(repo.holder_name, repo.name)

    # If invalid, display as such
    else
      # Redirect
      redirect_to repository_public_path(prefill_params), flash: { error: 'Incorrect CAPTCHA; please retry!' }
    end
  end

  def submitted
    @repository = current_resource
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

  def prefill_params
    params.permit(:username, :repositoryname, :name, :email, :issue_title, :details)
  end

  def current_resource
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])
    @current_resource ||= holder.repositories.find_by_name(params[:repositoryname])
  end

  def pass_captcha?
    simple_captcha_valid? && (!Rails.env.test? || session[:override_captcha])
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
