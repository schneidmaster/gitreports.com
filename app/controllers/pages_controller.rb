class PagesController < ApplicationController
  before_filter :ensure_signed_in!, only: [:profile]

  def profile
    @current_user = current_user
  end
end
