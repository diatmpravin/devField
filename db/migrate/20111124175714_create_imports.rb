class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :datatype
      t.integer :processed
      t.string :csv_file_name
      t.string :csv_content_type
      t.integer :csv_file_size

      t.timestamps
    end
  end
end
