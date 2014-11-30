class RepositoriesController < ApplicationController
  before_filter :ensure_own_repository!, except: [:repository, :repository_submit, :repository_submitted, :repository_rate_limited]
  before_filter :ensure_repository_active!, only: [:repository, :repository_submit, :repository_submitted, :repository_rate_limited]

  def repository
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])

    @repository = holder.repositories.find_by_name(params[:repositoryname])

    # Load any data from session
    if session[:issuedata]
      @name = session[:issuedata][:name]
      @email = session[:issuedata][:email]
      @details = session[:issuedata][:details]
      session[:issuedata] = nil
    end
  end

  def repository_submit
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])

    repo = holder.repositories.find_by_name(params[:repositoryname])

    # Check the captcha
    if simple_captcha_valid? && (!Rails.env.test? || session[:override_captcha])

      # Create the client
      client = Octokit::Client.new access_token: repo.access_token

      # Check the rate limit
      if client.rate_limit.remaining < 10
        redirect_to repository_rate_limited_path(repo.holder_name, repo.name)
      else
        # Create the issue
        name = repo.holder_name + '/' + repo.name
        issue_name = repo.issue_name.present? ? repo.issue_name : 'Git Reports Issue'
        labels = { labels: repo.labels.present? ? repo.labels : '' }
        client.create_issue(name, issue_name, repo.construct_body(params), labels)

        # Redirect
        redirect_to repository_submitted_path(repo.holder_name, repo.name)
      end

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

    if @repository.update(params[:repository].permit(:display_name, :issue_name, :prompt, :followup, :labels))
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
end
