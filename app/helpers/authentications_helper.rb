module AuthenticationsHelper
  def signed_in?
    if session[:user_id]
      true
    else
      false
    end
  end

  def current_user
    if signed_in?
      User.find(session[:user_id])
    else
      nil
    end
  end

  def current_access_token
    if signed_in?
      current_user.access_token
    else
      nil
    end
  end

  def ensure_signed_in!
    redirect_to login_path unless signed_in?
  end

  def ensure_own_repository!
    if !signed_in?
      redirect_to root_path
    elsif !Repository.find(params[:id]).check_owner(current_user)
      redirect_to profile_path
    end
  end

  def logout!
    session[:user_id] = nil
  end
end
