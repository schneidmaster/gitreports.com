module Controllers
  module SessionHelpers
    def log_in(user = create!(:user))
      session[:user_id] = user.id
    end
  end
end
