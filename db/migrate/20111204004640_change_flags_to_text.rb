class ChangeFlagsToText < ActiveRecord::Migration
  def change
  	remove_column :omx_requests, :verify_flag
  	remove_column :omx_requests, :queue_flag
  	add_column :omx_requests, :verify_flag, :string, :default => "True"
  	add_column :omx_requests, :queue_flag, :string, :default => "False"
  end
end
