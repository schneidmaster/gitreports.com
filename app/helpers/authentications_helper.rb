module AuthenticationsHelper
  def signed_in?
    !session[:user_id].nil?
  end

  def current_user
    signed_in? ? User.find(session[:user_id]) : nil
  end

  def current_access_token
    signed_in? ? current_user.access_token : nil
  end

  def ensure_signed_in!
    redirect_to login_path unless signed_in?
  end

  def ensure_own_repository!
    if !signed_in?
      redirect_to root_path
    elsif !Repository.exists?(params[:id])
      render 'repositories/404'
    elsif !Repository.find(params[:id]).check_owner(current_user)
      redirect_to profile_path
    end
  end

  def ensure_repository_active!
    holder = User.find_by_username(params[:username]) || Organization.find_by_name(params[:username])

    if holder.nil?
      render '404'
    else
      repo = holder.repositories.find_by_name(params[:repositoryname])
      render '404' if repo.nil? || !repo.is_active
    end
  end

  def logout!
    session[:user_id] = nil
  end
end
