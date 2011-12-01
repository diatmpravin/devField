desc "fetch mws orders"
task :mws_fetch_orders => :environment do
	puts MwsOrder.fetch_recent_orders("HDO")
	#puts MwsOrder.fetch_recent_orders("HDO Webstore")
	#puts MwsOrder.fetch_recent_orders("FieldDay")
end