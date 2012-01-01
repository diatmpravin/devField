class AddIconsToVendorAndStore < ActiveRecord::Migration
  def change
    add_column :vendors, :icon_file_name, :string
    add_column :vendors, :icon_content_type, :string
    add_column :vendors, :icon_file_size, :integer
    add_column :vendors, :icon_updated_at, :datetime

    add_column :stores, :icon_file_name, :string
    add_column :stores, :icon_content_type, :string
    add_column :stores, :icon_file_size, :integer
    add_column :stores, :icon_updated_at, :datetime 	
  end
end
