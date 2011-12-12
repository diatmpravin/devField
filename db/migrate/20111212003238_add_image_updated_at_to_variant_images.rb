class AddImageUpdatedAtToVariantImages < ActiveRecord::Migration
  def change
    add_column :variant_images, :image_updated_at, :datetime
  end
end
