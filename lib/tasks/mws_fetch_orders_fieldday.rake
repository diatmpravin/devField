desc "fetch mws orders fieldday"
task :mws_fetch_orders_fieldday => :environment do
	store = Store.find_by_name('FieldDay')
	store.fetch_recent_orders
	#store.reprocess_orders_missing_items
end