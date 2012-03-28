desc "refresh sku mapping"
task :refresh_sku_mapping => :environment do
	Product.refresh_all_sku_mappings
	MwsOrderItem.refresh_all_sku_mappings
end