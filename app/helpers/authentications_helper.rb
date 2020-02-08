module AuthenticationsHelper
  def signed_in?
    !session[:user_id].nil?
  end

  def current_user
    signed_in? ? User.find(session[:user_id]) : nil
  end

  def ensure_signed_in!
    redirect_to login_path unless signed_in?
  end

  def ensure_own_repository!
    id = params[:id] || params[:repository_id]
    if !signed_in?
      redirect_to root_path
    elsif !Repository.find_by(id: id)
      render 'not_found'
    elsif !Repository.find(id).users.include?(current_user)
      redirect_to profile_path
    end
  end

  def ensure_repository_active!
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])

    if holder.nil?
      render 'repositories/not_found'
    else
      repo = holder.repositories.find_by_name(params[:repositoryname])
      render 'repositories/not_found' if repo.nil? || !repo.is_active
    end
  end
end
