class CreateMwsResponses < ActiveRecord::Migration
  def change
    create_table :mws_responses do |t|
      t.integer :mws_request_id
      t.string :amazon_request_id
      t.text :next_token
      t.datetime :last_updated_before
      t.datetime :created_before
      t.string :request_type
      t.integer :page_num
      t.string :error_code
      t.text :error_message
      t.string :amazon_order_id

      t.timestamps
    end
  end
end
