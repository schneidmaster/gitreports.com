class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include AuthenticationsHelper
  include SimpleCaptcha::ControllerHelpers
end
