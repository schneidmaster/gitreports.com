class GithubRateLimitError < RuntimeError; end

class GithubService
  class << self
    def create_or_update_user(access_token)
      client = Octokit::Client.new access_token: access_token

      return nil if client.rate_limit.remaining < 10

      # Retrieve or update the user
      user = User.find_or_create_by(username: client.user[:login])
      user.update(access_token: access_token, name: client.user[:name], avatar_url: client.user[:avatar_url])
      user
    end

    def load_repositories(access_token)
      # Find user
      user = User.find_by_access_token(access_token)

      # Create client with token
      client = Octokit::Client.new access_token: access_token, auto_paginate: true
      return nil if client.rate_limit.remaining < 10

      old_repos = user.repositories.pluck(:github_id)
      old_orgs = user.organizations.pluck(:name)

      current_repos, current_orgs = add_repos(client.repos, user)

      # Add repos and remove user from any repos/orgs they no longer have access to
      remove_outdated(user, old_repos - current_repos)
      remove_outdated_orgs(user, old_orgs - current_orgs)
    end

    # rubocop:disable ParameterLists
    def submit_issue(repo_id, sub_name, email, email_public, title, details)
      # Find repo
      repo = Repository.find(repo_id)

      # Determine title
      issue_title = repo.allow_issue_title && !title.empty? ? title : 'Git Reports Issue'

      # Create client and check rate limit
      client = Octokit::Client.new access_token: repo.access_token
      raise GithubRateLimitError if client.rate_limit.remaining < 10

      # Create the issue
      issue = create_issue(client, repo, issue_title, repo.construct_body(sub_name, email, email_public, details))

      # Send notification email
      if repo.notification_emails.present?
        if repo.include_submitter_email
          NotificationMailer.issue_submitted_email(repo.id, issue.number, submitter_name: sub_name, submitter_email: email).deliver_later

        else
          NotificationMailer.issue_submitted_email(repo.id, issue.number).deliver_later
        end
      end

      issue
    end
    # rubocop:enable ParameterLists

    private

    def add_repos(repos, user)
      found_repo_ids = []
      found_org_names = []

      repos.select(&:has_issues).each do |api_repo|
        repo_attrs = {
          name: api_repo[:name],
          owner: api_repo[:owner][:login]
        }

        if api_repo[:owner][:type] == 'Organization'
          org_name = api_repo[:owner][:login]
          repo_attrs[:organization] = add_org(org_name, user)
          found_org_names << org_name unless found_org_names.include?(org_name)
        end

        if (repo = Repository.find_by_github_id(api_repo.id))
          # Update any information and ensure user is added
          repo.update(repo_attrs)
          repo.add_user!(user)

          found_repo_ids << api_repo.id.to_s
        # Else create it
        else
          repo_attrs.merge!(
            github_id: api_repo[:id],
            is_active: false,
            users: [user]
          )
          Repository.create(repo_attrs)
        end
      end

      [found_repo_ids, found_org_names]
    end

    def create_issue(client, repo, title, body)
      name = repo.holder_name + '/' + repo.name
      issue_name = repo.issue_name.present? ? repo.issue_name : title
      labels = { labels: repo.labels.present? ? repo.labels : '' }
      client.create_issue(name, issue_name, body, labels)
    end

    def add_org(org_name, user)
      org = Organization.find_or_create_by(name: org_name)

      # Make sure it's added to the user
      org.add_user!(user)

      org
    end

    def remove_outdated(user, old_ids)
      old_ids.each do |github_id|
        repo = Repository.find_by_github_id(github_id)

        # Delete user from repository
        repo.users.delete(user)

        # If the repo has no users left, disable it
        repo.update(is_active: false) if repo.users.count.zero?
      end
    end

    def remove_outdated_orgs(user, old_names)
      user.organizations.delete(Organization.where(name: old_names))
    end
  end
end
