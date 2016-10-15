class Repository < ActiveRecord::Base
  has_and_belongs_to_many :users, -> { order 'username ASC' } do
    def <<(user)
      super unless proxy_association.owner.users.include?(user)
    end
  end
  belongs_to :organization

  scope :user_owned, -> { where(organization: nil) }
  scope :with_user, ->(user) { joins(:users).where('users.id = ?', user) }

  validate :custom_field_length

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

  def construct_body(sub_name, email, email_public, details)
    body = ''
    body += "Submitter: #{sub_name}\r\n" unless sub_name.blank?
    body += "Email: #{email}\r\n" unless email.blank? if email_public == 'on'
    body += details unless details.blank?

    body
  end

  def display_or_name
    return display_name if display_name.present?
    name
  end

  def github_issues_path
    "#{holder_path}/#{name}/issues"
  end

  def github_issue_path(issue)
    "#{github_issues_path}/#{issue}"
  end

  private

  def custom_field_length
    %w(display_name issue_name prompt followup).each do |field|
      errors[field] << 'must be at least 5 characters' unless send(field).blank? || send(field).length >= 5
    end
  end
end
