class ChangeAmazonResponseIdToResponseIdInOrders < ActiveRecord::Migration
	def change
		rename_column :orders, :amazon_response_id, :response_id 
	end
end
