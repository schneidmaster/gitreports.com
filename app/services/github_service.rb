class GithubService
  class << self
    def create_or_update_user(access_token)
      Octokit.connection_options[:ssl] = { ca_file: File.join(Rails.root, 'config', 'cacert.pem') }
      client = Octokit::Client.new access_token: access_token

      if client.rate_limit.remaining < 10
        nil
      else
      
        # Save the local User to the database
        user = User.find_by_access_token(access_token)
        if user.present?
          user.update(username: client.user[:login], name: client.user[:name], gravatar_id: client.user[:gravatar_id])
        else
          user = User.create(username: client.user[:login], name: client.user[:name], gravatar_id: client.user[:gravatar_id], access_token: access_token)
        end

        user
      end
    end

    def load_repositories(access_token)
      # Find user
      user = User.find_by_access_token(access_token)

      # Create client with token
      Octokit.connection_options[:ssl] = { ca_file: File.join(Rails.root, 'config', 'cacert.pem') }
      client = Octokit::Client.new access_token: access_token

      # Autopaginate the client
      client.auto_paginate = true

      # Delete any outdated repos
      user.repositories.each do |repo|
        next unless client.repos.select { |r| r[:id] == repo.github_id.to_i }.count == 0
        user.repositories.delete(repo)

        # If the repo has no users left, disable it
        repo.update(is_active: false) if repo.users.count == 0
      end

      # Add their repositories
      client.repos.each do |api_repo|
        # See if the repo exists
        repo = Repository.find_by_github_id(api_repo.id)
        # If so, update its name and add the user if necessary
        if repo
          repo.update(name: api_repo[:name], owner: api_repo[:owner][:login])
          unless repo.users.any? { |u| u == user }
            repo.users << user
            repo.save
          end
        # Else create it
        else
          # Create the new repo
          repo = Repository.new(github_id: api_repo[:id], name: api_repo[:name], is_active: false)
          # Tie the repo to the user
          repo.users << user
          # Save the new repo
          repo.save
        end
      end

      # Delete any outdated orgs
      user.organizations.each do |org|
        next unless client.orgs.select { |r| r[:login] == org.name }.count == 0
        user.organizations.delete(org)
      end

      # Add their org repositories (if any), under the org name to keep it nice and neat
      client.orgs.each do |api_org|
        # See if the org exists
        org = Organization.find_by_name(api_org[:login])
        # If not, create it
        if org.nil?
          # Create the new org
          org = Organization.new(name: api_org[:login])
          # Tie the user to the org
          org.users << user
          # Save the org
          org.save
        else
          # If so, make sure it's added to the user
          unless user.organizations.any? { |o| o == org }
            # Tie the user to the org
            user.organizations << org
            # Save the user
            user.save
          end
        end
        # Delete any outdated org repos that belong to the user
        org.repositories.each do |repo|
          next unless api_org.rels[:repos].get.data.select { |r| r[:id] == repo.github_id.to_i }.count == 0
          repo.users.delete(user)

          # If the repo has no users left, disable it
          repo.update(is_active: false) if repo.users.count == 0
        end
        # Add or create the org's repos
        api_org.rels[:repos].get.data.each do |api_repo|
          # See if the repo exists
          repo = org.repositories.find_by_github_id(api_repo[:id])
          # If so, update its name and add the user if necessary
          if repo
            repo.update(name: api_repo[:name], owner: api_repo[:owner][:login])
            unless repo.users.any? { |u| u == user }
              repo.users << user
              repo.save
            end
          # Else create it
          else
            # Create the new repo
            repo = Repository.new(github_id: api_repo[:id], name: api_repo[:name], is_active: false)
            # Tie the repo to the org
            repo.organization = org
            # Tie the repo to the user
            repo.users << user
            # Save the new repo
            repo.save
          end
        end
      end
    end
  end
end