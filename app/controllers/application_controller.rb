class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include AuthenticationsHelper
  include MarkdownHelper
  include SimpleCaptcha::ControllerHelpers

  around_action :catch_halt

  before_action :ensure_production_host
  before_action :set_locale

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

  def ensure_production_host
    # Ensure hostname is gitreports.com -- not www or the heroku URL.
    return unless %w[gitreports.herokuapp.com www.gitreports.com].include?(request.host)
    redirect_to "https://gitreports.com#{request.fullpath}"
  end

  def set_locale
    I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales) || :en
  end
end
