desc "fetch mws orders"
task :mws_fetch_orders => :environment do
	puts MwsOrder.fetch_recent_orders("hdo")
end