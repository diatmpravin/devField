class AddStoreToMwsRequests < ActiveRecord::Migration
  def change
    add_column :mws_requests, :store, :string, :default => 'HDO'
  end
end
