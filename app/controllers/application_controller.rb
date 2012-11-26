class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_cache

  private

  def set_cache
    unless Rails.env.development?
      expires_in 5.minutes, :public => true
    end
  end
end
