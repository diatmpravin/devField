class AddStoreIdToMwsOrders < ActiveRecord::Migration
  def change
    add_column :mws_orders, :store_id, :integer
  end
end
