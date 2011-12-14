class AddUpcToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :upc, :string
  end
end
