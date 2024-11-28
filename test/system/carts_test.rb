require "application_system_test_case"

class CartsTest < ApplicationSystemTestCase
  setup do
    @buyer = users(:two)
    @product = products(:one)
    @product2 = products(:two)
    sign_in @buyer
    @buyer.cart.empty!
  end

  test "adding a product to the cart" do
    visit product_url(@product)
    click_on "Add to cart"
    assert_selector "turbo-frame#cartsize div", text: "1"
    assert_selector "button#add_to_cart_button", text: "Added to cart"
  end

  test "removing a product from the cart" do
    visit product_url(@product)
    click_on "Add to cart"
    visit product_url(@product2)
    click_on "Add to cart"
    visit cart_url

    assert_text @product.title
    first("button.remove-cart-item").click
    assert_no_text @product.title
    assert_selector "turbo-frame#cartsize div", text: "1"
  end

  test "displaying correct cart items and total amount on cart page" do
    visit product_url(@product)
    click_on "Add to cart"
    visit product_url(@product2)
    click_on "Add to cart"
    visit cart_url

    assert_text @product.title
    assert_text "$#{@product.price}"
    assert_text @product2.title
    assert_text "$#{@product2.price}"

    assert_text "$#{@buyer.cart.total_amount}"
  end

  test "checking out successfully" do
    visit product_url(@product)
    click_on "Add to cart"
    visit product_url(@product2)
    click_on "Add to cart"
    visit cart_url

    checkout_session = mock('checkout_session')
    checkout_session.stubs(:url).returns('http://localhost:3000/')
    checkout_session.stubs(:id).returns('cs_test_123')

    Stripe::Checkout::Session.expects(:create)
                             .returns(checkout_session)

    assert_difference("Order.count", 1) do
      click_on "Check Out"
    end

    assert_equal "http://localhost:3000/", page.current_url
  end

end
































