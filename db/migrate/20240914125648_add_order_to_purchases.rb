class AddOrderToPurchases < ActiveRecord::Migration[7.1]
  def change
    add_reference :purchases, :order, foreign_key: true
  end
end
