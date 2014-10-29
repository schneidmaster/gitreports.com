class PagesController < ApplicationController
  before_filter :ensure_signed_in!, only: [:profile]

  def home
  end

  def profile
    @current_user = current_user
  end

  def about
  end

  def tutorial
  end
end
