class RepositoriesController < ApplicationController
  before_filter :ensure_own_repository!, except: [:repository, :repository_submit, :repository_submitted, :repository_rate_limited]

  def repository
    holder = User.find_by_username(params[:username])
    holder = Organization.find_by_name(params[:username]) if holder.nil?

    if holder.nil?
      render '404'
    else
      repo = holder.repositories.find_by_name(params[:repositoryname])
      if repo.nil? || !repo.is_active
        render '404'
      else
        @repository = repo

        # Load any data from session
        if session[:issuedata]
          @name = session[:issuedata][:name]
          @email = session[:issuedata][:email]
          @details = session[:issuedata][:details]
          session[:issuedata] = nil
        end
      end
    end
  end

  def repository_submit
    holder = User.find_by_username(params[:username])
    holder = Organization.find_by_name(params[:username]) if holder.nil?

    if holder.nil?
      render '404'
    else
      repo = holder.repositories.find_by_name(params[:repositoryname])
      if repo.nil? || !repo.is_active
        render '404'
      else

        # Check the captcha
        if simple_captcha_valid?

          # Create the client
          Octokit.connection_options[:ssl] = { ca_file: File.join(Rails.root, 'config', 'cacert.pem') }
          client = Octokit::Client.new access_token: repo.access_token

          # Check the rate limit
          redirect_to repository_rate_limited_path(repo.holder_name, repo.name) if client.rate_limit.remaining < 10

          # Create the issue
          name = repo.holder_name + '/' + repo.name
          issue_name = repo.issue_name.present? ? repo.issue_name : 'Git Reports Issue'
          labels = { labels: repo.labels.present? ? repo.labels : '' }
          client.create_issue(name, issue_name, repo.construct_body(params), labels)

          # Redirect
          redirect_to repository_submitted_path(repo.holder_name, repo.name)

        # If invalid, display as much
        else

          # Store posted data in session
          session[:issuedata] = { name: params[:name], email: params[:email], details: params[:details] }

          # Redirect
          redirect_to repository_public_path(params[:username], params[:repositoryname]), flash: { error: 'Incorrect CAPTCHA; please retry!' }
        end
      end
    end
  end

  def repository_submitted
    holder = User.find_by_username(params[:username])
    holder = Organization.find_by_name(params[:username]) if holder.nil?

    if holder.nil?
      render '404'
    else
      repo = holder.repositories.find_by_name(params[:repositoryname])
      if repo.nil? || !repo.is_active
        render '404'
      else
        @repository = repo
      end
    end
  end

  def repository_rate_limited
    holder = User.find_by_username(params[:username])
    holder = Organization.find_by_name(params[:username]) if holder.nil?

    if holder.nil?
      render '404'
    else
      repo = holder.repositories.find_by_name(params[:repositoryname])
      if repo.nil? || !repo.is_active
        render '404'
      else
        @repo = repo

        # Create the client
        Octokit.connection_options[:ssl] = { ca_file: File.join(Rails.root, 'config', 'cacert.pem') }
        client = Octokit::Client.new access_token: @repo.access_token

        # Get the reset time
        @reset_time = client.rate_limit.resets_at

      end
    end
  end

  def repository_show
    repo = Repository.find(params[:id])
    if repo.nil?
      render '404'
    else
      @repository = repo
    end
  end

  def repository_edit
    repo = Repository.find(params[:id])
    if repo.nil?
      render '404'
    else
      @repository = repo
    end
  end

  def repository_update
    repo = Repository.find(params[:id])
    if repo.nil?
      render '404'
    else
      @repository = repo

      if @repository.update(params[:repository].permit(:display_name, :issue_name, :prompt, :followup, :labels))
        redirect_to repository_path(@repository)
      else
        render 'repository_edit'
      end
    end
  end

  def repository_activate
    repo = Repository.find(params[:id])
    if repo.nil?
      render '404'
    else
      repo.update(is_active: true)
      redirect_to repository_path(repo)
    end
  end

  def repository_deactivate
    repo = Repository.find(params[:id])
    if repo.nil?
      render '404'
    else
      repo.update(is_active: false)
      redirect_to repository_path(repo)
    end
  end
end
