class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.datetime :available_on
      t.datetime :deleted_at
      t.text :meta_description
      t.string :meta_keywords
      t.integer :brand_id

      t.timestamps
    end
  end
end
