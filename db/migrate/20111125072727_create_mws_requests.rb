class CreateMwsRequests < ActiveRecord::Migration
  def change
    create_table :mws_requests do |t|
      t.string :amazon_request_id
      t.string :request_type

      t.timestamps
    end
  end
end
