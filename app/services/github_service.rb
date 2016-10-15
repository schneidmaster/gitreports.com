class GithubService
  class << self
    def create_or_update_user(access_token)
      client = Octokit::Client.new access_token: access_token

      return nil if client.rate_limit.remaining < 10

      # Retrieve or update the user
      user = User.find_or_create_by(access_token: access_token)
      user.update(username: client.user[:login], name: client.user[:name], avatar_url: client.user[:avatar_url])
      user
    end

    def load_repositories(access_token)
      # Find user
      user = User.find_by_access_token(access_token)

      # Create client with token
      client = Octokit::Client.new access_token: access_token, auto_paginate: true
      return nil if client.rate_limit.remaining < 10

      old_repos = user.repositories.pluck(:github_id)
      current_user_repos = add_repos(client.repos, user)
      current_org_repos = add_orgs(client.orgs, user)

      outdated_repos = old_repos - current_user_repos - current_org_repos

      # Add repos and remove user from any repos they no longer have access to
      remove_outdated(user, outdated_repos)
    end

    # rubocop:disable ParameterLists
    def submit_issue(repo_id, sub_name, email, email_public, title, details)
      # Find repo
      repo = Repository.find(repo_id)

      # Determine title
      issue_title = (repo.allow_issue_title && !title.empty?) ? title : 'Git Reports Issue'

      # Create client and check rate limit
      client = Octokit::Client.new access_token: repo.access_token
      throw 'Rate limit reached' if client.rate_limit.remaining < 10

      # Create the issue
      issue = create_issue(client, repo, issue_title, repo.construct_body(sub_name, email, email_public, details))

      # Send notification email
      EmailWorker.perform_async NotificationMailer, :issue_submitted_email, repo.id, issue.number unless repo.notification_emails.blank?

      issue
    end
    # rubocop:enable ParameterLists

    private

    def add_orgs(orgs, user)
      # Record repo IDs that are found
      found_ids = []

      found_org_names = orgs.map do |api_org|
        # Add the org
        org = add_org(api_org, user)

        # Add or create the org's repos
        found_ids += add_repos(api_org.rels[:repos].get.data, user, org)

        # Return its name
        org.name
      end

      # Remove user from any orgs they're no longer part of
      remove_outdated_orgs(user, found_org_names)

      # Return found IDs
      found_ids || []
    end

    def add_repos(repos, user, org = nil)
      found_repo_ids = []

      repos.select(&:has_issues).each do |api_repo|
        if (repo = Repository.find_by_github_id(api_repo.id))
          # Update any information and ensure user is added
          repo.update(name: api_repo[:name], owner: api_repo[:owner][:login], organization: org)
          repo.users << user

          found_repo_ids << api_repo.id.to_s
        # Else create it
        else
          Repository.create(github_id: api_repo[:id], name: api_repo[:name], is_active: false, owner: api_repo[:owner][:login], organization: org, users: [user])
        end
      end

      found_repo_ids
    end

    def create_issue(client, repo, title, body)
      name = repo.holder_name + '/' + repo.name
      issue_name = repo.issue_name.present? ? repo.issue_name : title
      labels = { labels: repo.labels.present? ? repo.labels : '' }
      client.create_issue(name, issue_name, body, labels)
    end

    def add_org(api_org, user)
      org = Organization.find_or_create_by(name: api_org[:login])

      # Make sure it's added to the user
      org.users << user

      org
    end

    def remove_outdated(user, old_ids)
      old_ids.each do |github_id|
        # Delete user from repository
        (repo = Repository.find_by_github_id(github_id)).users.delete(user)

        # If the repo has no users left, disable it
        repo.update(is_active: false) if repo.users.count == 0
      end
    end

    def remove_outdated_orgs(user, old_names)
      user.organizations.delete(Organization.where.not(name: old_names))
    end
  end
end
