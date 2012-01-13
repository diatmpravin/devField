class CreateVariantUpdates < ActiveRecord::Migration
  def change
    create_table :variant_updates do |t|
      t.integer :variant_id
      t.float :price
      t.float :cost_price
      t.string :availability

      t.timestamps
    end
  end
end
