class CreateOmxRequests < ActiveRecord::Migration
  def change
    create_table :omx_requests do |t|
      t.string :ordermotion_request_id
      t.string :request_type

      t.timestamps
    end
  end
end
