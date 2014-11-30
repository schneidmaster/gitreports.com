class User < ActiveRecord::Base
  has_and_belongs_to_many :repositories, -> { order 'name ASC' }, uniq: true
  has_and_belongs_to_many :organizations, -> { order 'name ASC' }, uniq: true

  def github_path
    "https://github.com/#{username}"
  end

  def avatar_url
    if self[:avatar_url].blank?
      "https://github.com/identicons/#{username}.png"
    else
      self[:avatar_url]
    end
  end
end
