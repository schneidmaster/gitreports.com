class Repository < ActiveRecord::Base
  has_and_belongs_to_many :users, -> { order 'username ASC' } do
    def <<(user)
      super unless proxy_association.owner.users.include?(user)
    end  
  end
  belongs_to :organization

  scope :user_owned, -> { where(organization: nil) }
  scope :with_user, ->(user) { joins(:users).where('users.id = ?', user) }

  def access_token
    users.first.access_token
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
    "https://github.com/#{holder_name}"
  end

  def construct_body(name, email, details)
    body = ""
    body += "Submitter: #{name}\r\n" unless name.blank?
    body += "Email: #{email}\r\n" unless email.blank?
    body += details unless details.blank?
    body
  end

  def display_or_name
    return display_name if display_name.present?
    return name
  end

  def github_issues_path
    "#{holder_path}/#{name}/issues"
  end

  def github_issue_path(issue)
    "#{github_issues_path}/#{issue}"
  end
end
