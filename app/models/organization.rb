class Organization < ActiveRecord::Base
  has_and_belongs_to_many :users, -> { order 'username ASC' } do
    def <<(user)
      super unless proxy_association.owner.users.include?(user)
    end
  end
  has_many :repositories
end
