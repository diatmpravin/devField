class AddScrapedAtToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :scraped_at, :datetime
  end
end
