class AddAmazonResponseIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :amazon_response_id, :integer
  end
end
