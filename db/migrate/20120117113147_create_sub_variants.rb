class CreateSubVariants < ActiveRecord::Migration
  def change
    create_table :sub_variants do |t|
      t.integer :variant_id
      t.string :sku
      t.string :upc
      t.string :size
      t.string :availability

      t.timestamps
    end
  end
end
