class ApplicationController < ActionController::Base
  helper_method :current_cart

  def current_cart
    @current_cart ||= current_user&.cart if user_signed_in?
  end
end
