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

  def org_repo?
    organization.present?
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

  def construct_body(params)
    body ||= "Submitter: #{params[:name]}\r\n" unless params[:name].blank?
    body ||= "Email: #{params[:email]}\r\n" unless params[:email].blank?
    body ||= params[:details]
    body
  end

  def display_or_name
    return display_name if display_name.present?
    return name
  end

  def github_issues_path
    "#{holder_path}/#{name}/issues"
  end
end
