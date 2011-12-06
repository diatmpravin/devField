class AddParentMwsRequestIdToMwsRequests < ActiveRecord::Migration
  def change
    add_column :mws_requests, :parent_mws_request_id, :integer
  end
end
