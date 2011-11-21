class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.string :asin
      t.string :order_item_id
      t.string :seller_sku
      t.string :title
      t.integer :quantity_ordered
      t.integer :quantity_shipped
      t.float :item_price
      t.string :item_price_currency
      t.float :shipping_price
      t.string :shipping_price_currency
      t.float :gift_price
      t.string :gift_price_currency
      t.float :item_tax
      t.string :item_tax_currency
      t.float :shipping_tax
      t.string :shipping_tax_currency
      t.float :gift_tax
      t.string :gift_tax_currency
      t.float :shipping_discount
      t.string :shipping_discount_currency
      t.float :promotion_discount
      t.string :promotion_discount_currency
      t.string :gift_wrap_level
      t.string :gift_message_text

      t.timestamps
    end
  end
end
