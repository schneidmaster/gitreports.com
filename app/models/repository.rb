class Repository < ActiveRecord::Base
	belongs_to :user
	belongs_to :organization

	def access_token
		if self.organization
			self.organization.users.first.access_token
		else
			self.user.access_token
		end
	end

	def check_owner(user)
		if self.organization
			self.organization.users.any? {|u| u == user}
		else
			self.user == user
		end
	end

	def is_org_repo?
		if self.organization
			true
		else
			false
		end
	end

	def holder_name
		if self.organization
			self.organization.name
		else
			self.user.username
		end
	end

	def holder_path
		if self.organization
			'https://github.com/' + self.organization.name
		else
			'https://github.com/' + self.user.username
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
