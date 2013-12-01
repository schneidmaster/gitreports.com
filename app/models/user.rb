class User < ActiveRecord::Base
	has_many :repositories, -> { order "name ASC" }
	has_and_belongs_to_many :organizations, -> { order "name ASC" }

	def avatar_url(size = 96)
		'https://gravatar.com/avatar/' + self.gravatar_id + '?s=' + size.to_s
	end

	def github_path
		'https://github.com/' + self.username
	end
end
