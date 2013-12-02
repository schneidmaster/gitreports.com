class AuthenticationsController < ApplicationController

	def login
		if signed_in?
			redirect_to root_path, :flash => { :success => "Already logged in!" }
		else
			redirect_to auth_url
		end
	end

	def callback

		# Catch any errors gracefully
		begin

			# Check for the state (to avoid forgery)
			if params[:state] != state
				raise "state error"
			else
				delete_state!
			end

			# Set params for GitHub POST request
			req_params = Hash.new
			req_params[:client_id] = ENV['GITHUB_CLIENT_ID']
			req_params[:client_secret] = ENV['GITHUB_CLIENT_SECRET']
			req_params[:code] = params[:code]

			# Make POST request
			response = post_request('https://github.com', '/login/oauth/access_token', req_params)

			# Create client with response
			access_token = response['access_token']
			Octokit.connection_options[:ssl] = {:ca_file => File.join(Rails.root, 'config', 'cacert.pem')}
			client = Octokit::Client.new :access_token => access_token

			# Save the local User to the database
			user = User.find_by_access_token(access_token)

			if user.present?
				user.update(:username => client.user[:login], :name => client.user[:name], :gravatar_id => client.user[:gravatar_id])
			else
				user = User.create(:username => client.user[:login], :name => client.user[:name], :gravatar_id => client.user[:gravatar_id], :access_token => access_token)
			end

			# Log in the user
			session[:user_id] = user.id

			# Check the rate limit
			if client.rate_limit.remaining < 10
				redirect_to login_rate_limited_path
			end

			# Delete any outdated repos
			user.repositories.each do |repo|
				if client.repos.select {|r| r[:name] == repo.name }.count == 0
					repo.destroy
				end
			end

			# Add their repositories
			client.repos.each do |api_repo|

				# See if the repo exists
				repo = Repository.find_by_github_id(api_repo.id)

				# If so, update its name
				if repo
					repo.update(:name => api_repo[:name])
				# Else create it
				else

					# Create the new repo
					repo = Repository.new(:github_id => api_repo[:id], :name => api_repo[:name], :is_active => false)

					# Tie the repo to the user
					repo.user = user

					# Save the new repo
					repo.save

				end

			end

			# Delete any outdated orgs
			user.organizations.each do |org|
				if client.orgs.select {|r| r[:login] == org.name }.count == 0
					org.destroy
				end
			end

			# Add their org repositories (if any), under the org name to keep it nice and neat
			client.orgs.each do |api_org|

				# See if the org exists
				org = Organization.find_by_name(api_org[:login])

				# If not, create it
				if org.nil?

					# Create the new org
					org = Organization.new(:name => api_org[:login])

					# Save the org
					org.save

					# Tie the user to the org
					user.organizations << org

					# Save the user
					user.save

				else

					# If so, make sure it's added to the user 
					if !user.organizations.any? {|o| o == org }

						# Tie the user to the org
						user.organizations << org

						# Save the user
						user.save
					end

				end

				# Delete any outdated org repos
				org.repositories.each do |repo|
					if api_org.rels[:repos].get.data.select {|r| r[:name] == repo.name }.count == 0
						repo.destroy
					end
				end

				# Add or create the org's repos
				api_org.rels[:repos].get.data.each do |api_repo|

					# See if the repo exists
					repo = org.repositories.find_by_github_id(api_repo[:id])

					# If so, update its name
					if repo

						repo.update(:name => api_repo[:name])

					# Else create it
					else

						# Create the new repo
						repo = Repository.new(:github_id => api_repo[:id], :name => api_repo[:name], :is_active => false)

						# Tie the repo to the org
						repo.organization = org

						# Save the new repo
						repo.save

					end
				end
			end

			# Redirect to profile
			redirect_to profile_path, :flash => { :success => "Logged in!" }

		# If error, redirect with error message
		rescue
			logout!
			redirect_to root_path, :flash => { :error => "An error occurred; please try again" }
		end
	end

	def logout
		session[:user_id] = nil
		redirect_to root_path, :flash => { :notice => "Logged out!" }
	end

	def login_rate_limited
		if !signed_in?
			redirect_to root_path
		else
			Octokit.connection_options[:ssl] = {:ca_file => File.join(Rails.root, 'config', 'cacert.pem')}
			client = Octokit::Client.new :access_token => current_access_token
			@reset_time = client.rate_limit.resets_at

			logout!
		end
	end

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

			base_url = "https://github.com/login/oauth/authorize"
			redirect_uri = ENV['GITHUB_CALLBACK_URL']
			scopes = "repo"

			params = "client_id=" + ENV['GITHUB_CLIENT_ID']
			params += "&" + {redirect_uri: redirect_uri}.to_query
			params += "&" + {scope: scopes}.to_query
			params += "&state=" + state

			base_url + "?" + params
		end

		def post_request(url_raw, path_raw, req_params=nil)

            # Initialize HTTP library
            url = URI.parse(url_raw)
            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            http.ca_file = File.join(Rails.root, 'config', 'cacert.pem')

            # Generate path
            path = path_raw

            # Create the new request
            request = Net::HTTP::Post.new(path)

            # Add post params if they exist
            if req_params != nil
                request.set_form_data(req_params)
            end

            # Accept JSON
            request['accept'] = 'application/json'

            # Make request and return parsed result
            begin
                response = http.request(request)
            rescue Exception => e
                false
            else
                JSON.parse(response.body)
            end

        end
end
