class AddAmazonOrderIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :amazon_order_id, :string
  end
end
