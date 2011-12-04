class AddOrderResultsPerPageToStore < ActiveRecord::Migration
  def change
    add_column :stores, :order_results_per_page, :integer
    add_column :stores, :max_order_pages, :integer
    add_column :stores, :queue_flag, :string
    add_column :stores, :verify_flag, :string
  end
end
