class RemoveOrdermotionRequestIdFromOmxRequests < ActiveRecord::Migration
  def change
  	remove_column :omx_requests, :ordermotion_request_id
  end
end
