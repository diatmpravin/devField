desc "fetch mws orders webstore"
task :mws_fetch_orders_webstore => :environment do
	store = Store.find_by_name('HDO Webstore')
	store.fetch_recent_orders
	#store.reprocess_orders_missing_items
end