class Product < ApplicationRecord
  belongs_to :seller, class_name: "User"

  has_many :purchases, dependent: :destroy
  has_many :buyers, through: :purchases, class_name: "User"
  has_many :reviews, dependent: :destroy

  has_many :cart_items
  has_many :carts, through: :cart_items

  has_many_attached :images

  has_rich_text :description

  after_save :set_stripe_price_id, if: -> { stripe_price_id.nil? || saved_change_to_price? }

  def set_stripe_price_id
    stripe_price = Stripe::Price.create({
      currency: 'usd',
      unit_amount: (self.price * 100).to_i,
      product_data: {name: self.title },
    })
    self.update(stripe_price_id: stripe_price.id)
  end
end
