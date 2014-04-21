class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :locale
  before_action :set_locale

protected
  def locale
    I18n.locale
  end

private
  def set_locale
    if request.format.html?
      new_params = {}

      lang = (params[:locale] || extract_locale_from_accept_language_header || 'en').to_sym

      if !params[:locale] or I18n.locale != lang
        I18n.locale = lang
        new_params.merge!({locale: lang})
      end

      redirect_to params.merge(new_params) if params.merge(new_params) != params
    end
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].to_s.scan(/^[a-z]{2}/).first
  end

end
