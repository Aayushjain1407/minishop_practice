class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.decimal :total_amount, scale: 2, precision: 10, default: 0
      t.datetime :status_changed_at

      t.timestamps
    end
  end
end
