class GithubService
  class << self
    def create_or_update_user(access_token)
      client = Octokit::Client.new access_token: access_token

      return nil if client.rate_limit.remaining < 10

      # Save the local User to the database
      if (user = User.find_by_access_token(access_token))
        user.update(username: client.user[:login], name: client.user[:name], gravatar_id: client.user[:gravatar_id])
      else
        user = User.create(username: client.user[:login], name: client.user[:name], gravatar_id: client.user[:gravatar_id], access_token: access_token)
      end

      user
    end

    def load_repositories(access_token)
      # Find user
      user = User.find_by_access_token(access_token)

      # Create client with token
      client = Octokit::Client.new access_token: access_token

      return nil if client.rate_limit.remaining < 10

      # Autopaginate the client
      client.auto_paginate = true

      # Record IDs to delete ones no longer in use
      old_ids = user.repositories.pluck(:github_id)

      # Add user repositories
      client.repos.select { |repo| repo[:has_issues] }.each do |api_repo|
        if (repo = Repository.find_by_github_id(api_repo.id))
          # Remove from delete list
          old_ids.delete(api_repo.id.to_s)

          # Update any information and ensure user is added
          repo.update(name: api_repo[:name], owner: api_repo[:owner][:login])
          repo.users << user
        # Else create it
        else
          Repository.create(github_id: api_repo[:id], name: api_repo[:name], is_active: false, users: [user])
        end
      end

      # Record org IDs to delete ones no longer in use
      old_org_names = user.organizations.pluck(:name)

      # Add their org repositories (if any), under the org name to keep it nice and neat
      client.orgs.each do |api_org|
        if (org = Organization.find_by_name(api_org[:login]))
          # Remove from delete list
          old_org_names.delete(api_org[:login])
          # Make sure it's added to the user
          org.users << user
        else
          # Create the new org
          org = Organization.create(name: api_org[:login], users: [user])
        end

        # Add or create the org's repos
        api_org.rels[:repos].get.data.select { |repo| repo[:has_issues] }.each do |api_repo|
          if (repo = org.repositories.find_by_github_id(api_repo[:id]))
            # Remove from delete list
            old_ids.delete(api_repo.id.to_s)

            # Update any information and ensure user is added
            repo.update(name: api_repo[:name], owner: api_repo[:owner][:login])
            repo.users << user
          else
            Repository.create(github_id: api_repo[:id], name: api_repo[:name], is_active: false, organization: org, users: [user])
          end
        end
      end

      # Remove user from any orgs they're no longer part of
      user.organizations.where(name: old_org_names).delete_all

      # Remove user from any repos they no longer have access to
      old_ids.each do |github_id|
        repo = Repository.find_by_github_id(github_id)
        repo.users.delete(user)

        # If the repo has no users left, disable it
        repo.update(is_active: false) if repo.users.count == 0
      end
    end
  end
end
