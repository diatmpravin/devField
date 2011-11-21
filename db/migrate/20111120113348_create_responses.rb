class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses, :force => true do |t|
      t.integer :request_id
      t.string :amazon_request_id
      t.text :next_token
      t.datetime :last_updated_before
      t.datetime :created_before
      t.string :request_type
      t.integer :page_num
      t.string :error_code
      t.text :error_message

      t.timestamps
    end
  end
end
