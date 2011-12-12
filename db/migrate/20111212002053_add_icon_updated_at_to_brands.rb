class AddIconUpdatedAtToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :icon_updated_at, :datetime
  end
end
