class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :amazon_request_id
      t.string :type

      t.timestamps
    end
  end
end
