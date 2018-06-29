require 'active_support/concern'

module SessionManagement::ApplicationController
  extend ActiveSupport::Concern

  def log_in(user, opts = {})
    if opts[:permanent]
      cookies.permanent[:auth_token] = user.auth_token
    elsif opts[:provider]
      cookies[:auth_token] = { value: user.auth_token, expires: 1.week.from_now }
    else
      cookies[:auth_token] = user.auth_token
    end
  end

  def current_user
    @current_user ||= begin
      if cookies[:auth_token]
        user = ::User.find_by_auth_token(cookies[:auth_token])
        cookies.delete(:auth_token) if ! user
        user
      end
    end
  end

  def signed_in?
    !!current_user
  end

  included do
    helper_method :current_user, :signed_in?
  end

  def require_user(notice = 'You need to log in first.', opts = {})
    if ! current_user
      store_location

      flash[:notice] = notice
      redirect_path = opts[:redirect_path] || log_in_path
      redirect_to redirect_path
    end
  end

  # Store a return_to location, but only if this was a GET request.
  # We can return to this location by calling #redirect_back_or_default.
  def store_location(custom_location = nil)
    session[:return_to] = custom_location || (request.get? ? request.url : nil)
  end

  def redirect_back_or_default(default = nil, opts = {})
    redirect_to((session[:return_to] || default || dashboard_path), opts)
    session[:return_to] = nil
  end

end