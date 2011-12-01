class AddMwsOrderIdToOmxRequests < ActiveRecord::Migration
  def change
    add_column :omx_requests, :mws_order_id, :integer
    add_column :omx_requests, :keycode, :string
    add_column :omx_requests, :queue_flag, :boolean
    add_column :omx_requests, :verify_flag, :boolean    
    remove_column :omx_requests, :omx_request_id
  end
end
