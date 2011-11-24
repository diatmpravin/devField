desc "fetch amazon orders"
task :fetch_amazon_orders => :environment do
	puts Order.fetch_amazon_orders("hdo")
end