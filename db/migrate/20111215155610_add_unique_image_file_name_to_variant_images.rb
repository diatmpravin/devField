class AddUniqueImageFileNameToVariantImages < ActiveRecord::Migration
  def change
    add_column :variant_images, :unique_image_file_name, :string
    add_index :variant_images, :unique_image_file_name 
  end
end
