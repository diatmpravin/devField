class ChangeErrorDataToText < ActiveRecord::Migration
  def change
    change_table :omx_responses do |t|
      t.change :error_data, :text
    end
  end
end
