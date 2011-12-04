class RenameErrorsToErrorDataInOmxResponse < ActiveRecord::Migration
  def change
  	rename_column :omx_responses, :errors, :error_data
  end
end
