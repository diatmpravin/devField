class RenameTypeInRequests < ActiveRecord::Migration
  def change
  	rename_column :requests, :type, :request_type
  end
end
