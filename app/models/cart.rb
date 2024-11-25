class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items
  has_many :products, through: :cart_items

  def total_amount
    products.sum(:price)
  end

  def empty!
    cart_items.destroy_all
  end

  def is_empty?
    cart_items.empty?
  end
end
