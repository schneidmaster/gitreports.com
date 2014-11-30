class Repository < ActiveRecord::Base
  has_and_belongs_to_many :users, -> { order 'username ASC' }, uniq: true
  belongs_to :organization

  scope :user_owned, -> { where(organization: nil) }
  scope :with_user, ->(user) { joins(:users).where('users.id = ?', user) }

  def user=(user)
    users << user unless users.include?(user)
  end

  def access_token
    users.first.access_token
  end

  def check_owner(user)
    users.any? { |u| u == user }
  end

  def org_repo?
    if organization
      true
    else
      false
    end
  end

  def holder_name
    if owner
      owner
    elsif organization
      organization.name
    else
      users.first.username
    end
  end

  def holder_path
    'https://github.com/' + holder_name
  end

  def construct_body(params)
    body = ''
    if params[:name] && params[:name] != ''
      body += 'Submitter: ' + params[:name] + "\r\n"
    end
    if params[:email] && params[:email] != ''
      body += 'Email: ' + params[:email] + "\r\n"
    end
    body += params[:details]

    body
  end

  def display_or_name
    if display_name.present?
      display_name
    else
      name
    end
  end

  def github_path
    holder_path + '/' + name
  end

  def github_issues_path
    github_path + '/issues'
  end
end
