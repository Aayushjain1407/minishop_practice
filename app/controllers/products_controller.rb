class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show buy ]
  before_action :set_seller_product, only: %i[ edit update destroy ]
  before_action :authenticate_user!, only: %i[ new create edit update destroy buy ]

  protect_from_forgery except: :webhook

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
    @reviews = @product.reviews.order("created_at DESC")
    @new_review = @product.reviews.new(user_id: current_user&.id)
  end

  def buy
    session = Stripe::Checkout::Session.create({
      client_reference_id: @product.id,
      line_items: [{
        price: @product.stripe_price_id,
        quantity: 1
      }],
      customer_email: current_user&.email,
      mode: 'payment',
      success_url: product_url(@product),
      cancel_url: product_url(@product),
    })
    redirect_to session.url, status: 303, allow_other_host: true
  end
  # GET /products/new
  def new
    @product = current_user.products.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = current_user.products.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_seller_product
      @product = current_user.products.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :root, alert: "Product not found" and return
    end

    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:title, :description, :price, :seller_id, images: [])
    end
end
