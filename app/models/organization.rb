class Organization < ApplicationRecord
  has_and_belongs_to_many :users, -> { order 'username ASC' }
  has_many :repositories

  include HasUniqueUsers
end
