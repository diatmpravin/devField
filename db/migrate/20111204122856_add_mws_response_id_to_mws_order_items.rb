class AddMwsResponseIdToMwsOrderItems < ActiveRecord::Migration
  def change
    add_column :mws_order_items, :mws_response_id, :integer
  end
end
