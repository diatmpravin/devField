class AddErrorsToOmxResponse < ActiveRecord::Migration
  def change
    add_column :omx_responses, :errors, :string
  end
end
