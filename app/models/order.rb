class Order < ApplicationRecord
  belongs_to :user
  has_many :purchases
  has_many :products, through: :purchases

  accepts_nested_attributes_for :purchases

  enum status: {
    pending: 0,
    processing: 1,
    fulfilled: 2,
    cancelled: 3,
    refunded: 4
  }

  scope :fulfilled, -> { where(status: :fulfilled) }
  
end
