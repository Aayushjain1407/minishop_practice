class CartItemsController < ApplicationController
  before_action :set_cart_item, only: %i[ destroy ]
  before_action :authenticate_user!

  # POST /cart_items or /cart_items.json
  def create
    @cart = Cart.find_or_create_by(user_id: current_user.id)
    @product = Product.find(params[:product_id])
    @cart.add(@product)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("add_to_cart_button",
            partial: "shared/add_to_cart_button",
            locals: {product: @product }),
          turbo_stream.update("cartsize", partial: "carts/cart_item_count")
        ]
      }
    end
  end

  # DELETE /cart_items/1 or /cart_items/1.json
  def destroy
    current_cart.remove(@cart_item.product)

    respond_to do |format|
      format.html { redirect_to cart_url, notice: "Product removed from your cart." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart_item
      @cart_item = CartItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cart_item_params
      params.require(:cart_item).permit(:cart_id, :product_id)
    end
end
