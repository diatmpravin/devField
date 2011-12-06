class RenameParentMwsRequestIdInMwsRequests < ActiveRecord::Migration
  def change
  	rename_column :mws_requests, :parent_mws_request_id, :mws_request_id
  end
end
