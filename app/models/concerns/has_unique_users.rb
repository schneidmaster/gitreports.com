module HasUniqueUsers
  extend ActiveSupport::Concern

  included do
    def add_user!(user)
      return if users.include?(user)
      users << user
    end
  end
end
