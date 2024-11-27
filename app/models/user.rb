class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_photo

  #Seller
  has_many :products, foreign_key: :seller_id, dependent: :destroy

  #Buyer
  has_many :purchases, foreign_key: :buyer_id, dependent: :destroy

  has_many :reviews, dependent: :destroy

  has_one :cart
  has_many :orders

  has_many :subscriptions
  has_one :active_subscription, -> { where(status: ['active', 'trialing']) },
          class_name: 'Subscription'

  def has_purchased?(product)
    orders.fulfilled.joins(:purchases).exists?(purchases: { product_id: product.id })
  end

  def is_pro_seller?
    active_subscription.present?
  end

  def setup_stripe_customer
    return if stripe_customer_id.present?
    customer = Stripe::Customer.create(email: email)
    update(stripe_customer_id: customer.id)
  end
end
