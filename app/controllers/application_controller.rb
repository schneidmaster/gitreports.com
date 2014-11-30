class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include AuthenticationsHelper
  include SimpleCaptcha::ControllerHelpers

  around_action :catch_halt

  def render(*args)
    super
    throw :halt
  end

  def redirect_to(*args)
    super
    throw :halt
  end

  protected

  def catch_halt
    catch :halt do
      yield
    end
  end
end
