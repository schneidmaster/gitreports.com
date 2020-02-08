class IssuesController < ApplicationController
  before_action :ensure_repository_active!

  def new
    @repository = current_resource

    # Set each param passed in the URL.
    %w[name email email_public issue_title details].each do |p|
      instance_variable_set("@#{p}", params[p.intern])
    end

    # If not specifically overridden to something, keep the email
    # public box checked by default.
    @email_public = '1' if @email_public.nil?
  end

  def create
    repo = current_resource

    # Check the captcha
    if pass_captcha?

      # Submit issue
      GithubJob.perform_later('submit_issue', repo.id, params[:name], params[:email], params[:email_public] == '1', params[:issue_title], params[:details])

      # Redirect
      redirect_to submitted_path(repo.holder_name, repo.name)

    # If invalid, display as such
    else
      # Redirect
      redirect_to repository_public_path(prefill_params.merge(email_public: params[:email_public] || '0')), flash: { error: 'Incorrect CAPTCHA; please retry!' }
    end
  end

  def created
    @repository = current_resource
  end

  private

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
end
