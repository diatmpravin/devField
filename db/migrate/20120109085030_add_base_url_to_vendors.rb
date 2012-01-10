class AddBaseUrlToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :base_url, :string
    add_column :vendors, :login_url, :string
    add_column :vendors, :username, :string
    add_column :vendors, :password, :string
  end
end
