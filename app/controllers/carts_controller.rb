class CartsController < ApplicationController
  before_action :set_cart
  before_action :authenticate_user!
  before_action :ensure_cart_not_empty, only: [:checkout]

  # GET /carts/1 or /carts/1.json
  def show
  end

  def checkout
    order = current_user.orders.create!(
      status: :pending,
      total_amount: @cart.total_amount,
      purchases_attributes: @cart.products.map do |product|
        {
          product: product,
          buyer: current_user
        }
      end
    )

    session = Stripe::Checkout::Session.create({
      client_reference_id: order.id,
      line_items: @cart.products.map { | product|
        {
          price: product.stripe_price_id,
          quantity: 1
        }
      },
      customer_email: current_user&.email,
      mode: 'payment',
      success_url: order_url(order),
      cancel_url: cart_url,
    })
    redirect_to session.url, status: 303, allow_other_host: true

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = current_user.cart
    end

    # Only allow a list of trusted parameters through.
    def cart_params
      params.require(:cart).permit(:user_id)
    end

    def ensure_cart_not_empty
      if @cart.is_empty?
        redirect_to cart_path, alert: "Your cart is empty"
      end
    end
end
