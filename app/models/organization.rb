class Organization < ActiveRecord::Base
  has_and_belongs_to_many :users, -> { order 'username ASC' }, uniq: true
  has_many :repositories

  def user=(user)
    users << user unless users.include?(user)
  end
end
