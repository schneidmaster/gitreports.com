module Features
  module SessionHelpers
    def log_in(user = create!(:user))
      page.set_rack_session(user_id: user.id)
    end

    def override_captcha(value)
      page.set_rack_session(override_captcha: value)
    end
  end
end
