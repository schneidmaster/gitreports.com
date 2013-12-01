class RepositoriesController < ApplicationController
	before_filter :ensure_own_repository!, except: [:repository, :repository_submit, :repository_submitted]

	def repository

		holder = User.find_by_username(params[:username])
		if holder.nil?
			holder = Organization.find_by_name(params[:username])
		end

		if holder.nil?
			render '404'
		else
			repos = holder.repositories.where(:name => params[:repositoryname])
			if repos.count == 0 || !repos.first.is_active
				render '404'
			else
				@repository = repos.first
			end
		end
	end

	def repository_submit

		holder = User.find_by_username(params[:username])
		if holder.nil?
			holder = Organization.find_by_name(params[:username])
		end

		if holder.nil?
			render '404'
		else
			repos = holder.repositories.where(:name => params[:repositoryname])
			if repos.count == 0 || !repos.first.is_active
				render '404'
			else
				repo = repos.first

				# Create the client
				Octokit.connection_options[:ssl] = {:ca_file => File.join(Rails.root, 'config', 'cacert.pem')}
				client = Octokit::Client.new :access_token => repo.access_token
				
				# Create the issue
				client.create_issue(repo.holder_name + "/" + repo.name, repo.issue_name.present? ? repo.issue_name : "Git Reports Issue", repo.construct_body(params), {:labels => repo.labels.present? ? repo.labels : ""})

				# Redirect
				redirect_to repository_submitted_path(repo.holder_name, repo.name)
			end
		end

	end

	def repository_submitted

		holder = User.find_by_username(params[:username])
		if holder.nil?
			holder = Organization.find_by_name(params[:username])
		end

		if holder.nil?
			render '404'
		else
			repos = holder.repositories.where(:name => params[:repositoryname])
			if repos.count == 0 || !repos.first.is_active
				render '404'
			else
				@repository = repos.first
			end
		end

	end

	def repository_show
		repo = Repository.find(params[:id])
		if repo.nil?
			render '404'
		else
			@repository = repo
		end
	end

	def repository_edit
		repo = Repository.find(params[:id])
		if repo.nil?
			render '404'
		else
			@repository = repo
		end
	end

	def repository_update
		repo = Repository.find(params[:id])
		if repo.nil?
			render '404'
		else
			@repository = repo

			if @repository.update(params[:repository].permit(:display_name, :issue_name, :prompt, :followup, :labels))
				redirect_to repository_path(@repository)
			else
		    	render 'repository_edit'
		    end
		end
	end

	def repository_activate
		repo = Repository.find(params[:id])
		if repo.nil?
			render '404'
		else
			repo.update(:is_active => true)
			redirect_to repository_path(repo)
		end
	end

	def repository_deactivate
		repo = Repository.find(params[:id])
		if repo.nil?
			render '404'
		else
			repo.update(:is_active => false)
			redirect_to repository_path(repo)
		end
	end

end
