class AddShipmentServiceLevelCategoryToMwsOrders < ActiveRecord::Migration
  def change
    add_column :mws_orders, :shipment_service_level_category, :string
    add_column :mws_orders, :name, :string
    remove_column :mws_orders, :ship_service_level_category
  end
end
