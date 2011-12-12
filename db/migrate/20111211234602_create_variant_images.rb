class CreateVariantImages < ActiveRecord::Migration
  def change
    create_table :variant_images do |t|
      t.integer :variant_id
      t.string :image_file_name
      t.string :image_content_type
      t.string :image_file_size

      t.timestamps
    end
  end
end
