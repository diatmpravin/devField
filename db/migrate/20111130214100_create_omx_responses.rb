class CreateOmxResponses < ActiveRecord::Migration
  def change
    create_table :omx_responses do |t|
      t.integer :omx_request_id
      t.integer :success
      t.string :ordermotion_response_id
      t.string :ordermotion_order_number

      t.timestamps
    end
  end
end
