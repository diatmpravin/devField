class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :raw_state
      t.string :clean_state

      t.timestamps
    end
  end
end
