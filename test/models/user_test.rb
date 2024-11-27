require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:one)
  end

  test "should check if user has purchased a product" do
    product = products(:one)
    @user.orders.create!(
      status: :fulfilled,
      total_amount: 10,
      purchases_attributes: [
        {
          product: product,
          buyer: @user
        }
      ]
    )
    assert @user.has_purchased?(product)
  end

  test "should check if a seller is pro" do
    assert_not @user.is_pro_seller?
    subscription = @user.subscriptions.create!(status: 'active')
    @user.reload
    assert @user.is_pro_seller?
  end

  test "should set up Stripe customer" do
    Stripe::Customer.expects(:create).with(email: @user.email)
                    .returns(OpenStruct.new(id: "stripe_customer_id"))
    @user.setup_stripe_customer

    assert_not_nil @user.stripe_customer_id
    assert_equal "stripe_customer_id", @user.stripe_customer_id
  end


end













