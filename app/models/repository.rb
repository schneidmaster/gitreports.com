class Repository < ActiveRecord::Base
	has_and_belongs_to_many :users, -> { order "username ASC" }
	belongs_to :organization

	def access_token
		self.users.first.access_token
	end

	def check_owner(user)
		self.users.any? {|u| u == user}
	end

	def is_org_repo?
		if self.organization
			true
		else
			false
		end
	end

	def holder_name
		if self.owner
			self.owner
		elsif self.organization
			self.organization.name
		else
			self.users.first.username
		end
	end

	def holder_path
		'https://github.com/' + 
			if self.owner
				self.owner
			elsif self.organization
				self.organization.name
			else
				self.users.first.username
			end
	end

	def construct_body(params)
		body = ""
		if params[:name] && params[:name] != ""
			body += "Submitter: " + params[:name] + "\r\n"
		end
		if params[:email] && params[:email] != ""
			body += "Email: " + params[:email] + "\r\n"
		end
		body += params[:details]

		body
	end

	def display_or_name
		if self.display_name.present?
			self.display_name
		else
			self.name
		end
	end

	def github_path
		holder_path + '/' + self.name
	end

	def github_issues_path
		github_path + '/issues'
	end

end
