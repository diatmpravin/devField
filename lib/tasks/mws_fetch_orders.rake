desc "fetch mws orders"
task :mws_fetch_orders => :environment do
	puts Store.find_by_name("HDO").fetch_recent_orders
end