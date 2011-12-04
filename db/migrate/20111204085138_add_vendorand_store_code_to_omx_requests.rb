class AddVendorandStoreCodeToOmxRequests < ActiveRecord::Migration
  def change
    add_column :omx_requests, :vendor, :string
    add_column :omx_requests, :store_code, :string
  end
end
