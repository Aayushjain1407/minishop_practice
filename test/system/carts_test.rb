require "application_system_test_case"

class CartsTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
    @product = products(:one)
    @product2 = products(:two)
    sign_in @user
    @user.cart.empty!
  end
end
