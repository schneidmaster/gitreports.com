module Features
  module SessionHelpers
    def log_in(user = create!(:user))
      page.set_rack_session(user_id: user.id)
    end

    def post_request(path)
      page.driver.post path
    end
  end
end