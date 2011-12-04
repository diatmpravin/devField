class AddStoreIdToMwsRequests < ActiveRecord::Migration
  def change
    add_column :mws_requests, :store_id, :integer
    remove_column :mws_requests, :store
  end
end
