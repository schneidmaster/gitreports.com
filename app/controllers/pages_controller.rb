class PagesController < ApplicationController
  before_action :ensure_signed_in!

  def profile
    @current_user = current_user
  end
end
