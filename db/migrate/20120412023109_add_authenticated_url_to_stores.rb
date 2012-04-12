class AddAuthenticatedUrlToStores < ActiveRecord::Migration
  def change
    add_column :stores, :authenticated_url, :string
  end
end
