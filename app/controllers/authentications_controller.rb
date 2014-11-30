class AuthenticationsController < ApplicationController
  def login
    if signed_in?
      redirect_to root_path, flash: { success: 'Already logged in!' }
    else
      redirect_to auth_url
    end
  end

  def callback
    # Catch any errors gracefully
    if params[:state] != state
      redirect_to root_path, flash: { error: 'An error occurred; please try again' }
    else
      delete_state!

      # Set params for GitHub POST request
      req_params = {}
      req_params[:client_id] = ENV['GITHUB_CLIENT_ID']
      req_params[:client_secret] = ENV['GITHUB_CLIENT_SECRET']
      req_params[:code] = params[:code]

      # Make POST request
      response = post_request('https://github.com', '/login/oauth/access_token', req_params)

      if response.nil?
        redirect_to root_path, flash: { error: 'An error occurred; please try again' }
      else
        access_token = response['access_token']

        # Create or update user
        if user = GithubService.create_or_update_user(access_token)
          # Log in the user
          session[:user_id] = user.id

          # Add repositories
          if GithubService.load_repositories(access_token)
            # Redirect to profile
            redirect_to profile_path, flash: { success: 'Logged in!' }
          else
            redirect_to login_rate_limited_path
          end
        else
          redirect_to login_rate_limited_path
        end
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path, flash: { notice: 'Logged out!' }
  end

  def login_rate_limited; end

  private

  def state
    if session[:state]
      session[:state]
    else
      state = SecureRandom.hex
      session[:state] = state
      state
    end
  end

  def delete_state!
    session[:state] = nil
  end

  def auth_url
    base_url = 'https://github.com/login/oauth/authorize'
    redirect_uri = ENV['GITHUB_CALLBACK_URL']
    scopes = 'repo'

    params = 'client_id=' + ENV['GITHUB_CLIENT_ID']
    params += '&' + { redirect_uri: redirect_uri }.to_query
    params += '&' + { scope: scopes }.to_query
    params += '&state=' + state

    base_url + '?' + params
  end

  def post_request(url_raw, path_raw, req_params = nil)
    # Initialize HTTP library
    url = URI.parse(url_raw)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    # Generate path
    path = path_raw

    # Create the new request
    request = Net::HTTP::Post.new(path)

    # Add post params if they exist
    request.set_form_data(req_params) unless req_params.nil?

    # Accept JSON
    request['accept'] = 'application/json'

    # Make request and return parsed result
    begin
      response = http.request(request)
    rescue
      nil
    else
      JSON.parse(response.body)
    end
  end
end
