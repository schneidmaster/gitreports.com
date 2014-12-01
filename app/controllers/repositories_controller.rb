class RepositoriesController < ApplicationController
  before_filter :ensure_own_repository!, except: [:load_status, :repository, :repository_submit, :repository_submitted, :repository_rate_limited]
  before_filter :ensure_repository_active!, only: [:repository, :repository_submit, :repository_submitted, :repository_rate_limited]

  def load_status
    render text: 
      if session[:job_id]
        Sidekiq::Status::complete?(session[:job_id])
      else
        true
      end
  end

  def repository
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])

    @repository = holder.repositories.find_by_name(params[:repositoryname])

    # Load any data from session
    return unless session[:issuedata]
    @name = session[:issuedata][:name]
    @email = session[:issuedata][:email]
    @details = session[:issuedata][:details]
    session.delete(:issuedata)
  end

  def repository_submit
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])

    repo = holder.repositories.find_by_name(params[:repositoryname])

    # Check the captcha
    if simple_captcha_valid? && (!Rails.env.test? || session[:override_captcha])

      # Submit issue
      GithubWorker.perform_async(:submit_issue, repo.id, params[:name], params[:email], params[:details])

      # Redirect
      redirect_to repository_submitted_path(repo.holder_name, repo.name)

    # If invalid, display as such
    else

      # Store posted data in session
      session[:issuedata] = { name: params[:name], email: params[:email], details: params[:details] }

      # Redirect
      redirect_to repository_public_path(params[:username], params[:repositoryname]), flash: { error: 'Incorrect CAPTCHA; please retry!' }
    end
  end

  def repository_submitted
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])

    @repository = holder.repositories.find_by_name(params[:repositoryname])
  end

  def repository_rate_limited
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])

    @repo = holder.repositories.find_by_name(params[:repositoryname])

    # Create the client
    client = Octokit::Client.new access_token: @repo.access_token

    # Get the reset time
    @reset_time = client.rate_limit.resets_at
  end

  def repository_show
    @repository = Repository.find(params[:id])
  end

  def repository_edit
    @repository = Repository.find(params[:id])
  end

  def repository_update
    @repository = Repository.find(params[:id])

    if @repository.update(repository_params)
      redirect_to repository_path(@repository)
    else
      render 'repository_edit'
    end
  end

  def repository_activate
    repo = Repository.find(params[:id])
    repo.update(is_active: true)
    redirect_to repository_path(repo)
  end

  def repository_deactivate
    repo = Repository.find(params[:id])
    repo.update(is_active: false)
    redirect_to repository_path(repo)
  end

  private

  def repository_params
    params[:repository].permit(:display_name, :issue_name, :prompt, :followup, :labels).merge(notification_emails: parse_emails(params[:repository][:notification_emails]))
  end

  def parse_emails(emails)
    valid_emails = []
    unless emails.nil?
      emails.split(/,|\n/).each do |full_email|
        unless full_email.blank?
          if full_email.index(/\<.+\>/)
            email = full_email.match(/\<.*\>/)[0].gsub(/[\<\>]/, "").strip
          else
            email = full_email.strip
          end
          email = email.delete("<").delete(">")
          valid_emails << email if ValidateEmail.valid?(email)
        end
      end                    
    end
    return valid_emails.join(', ')
  end
end
