class AddImageWidthToVariantImages < ActiveRecord::Migration
  def change
    add_column :variant_images, :image_width, :integer
  end
end
