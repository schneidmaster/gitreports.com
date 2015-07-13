class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include AuthenticationsHelper
  include MarkdownHelper
  include SimpleCaptcha::ControllerHelpers

  around_action :catch_halt

  before_filter :redirect_if_heroku
  before_filter :set_locale

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

  private

  def redirect_if_heroku
    redirect_to "https://gitreports.com#{request.fullpath}" if request.host == 'gitreports.herokuapp.com'
  end

  def set_locale
    I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales) || :en
  end
end
