desc "fetch tifosi 2011 images"
task :fetch_tifosi_2011 => :environment do
	require 'mechanize'			
	agent = Mechanize.new
	agent.get("http://www.tifosioptics.com/files/2011%20Dealer%20Info%20and%20Pics/2011%20Product%20Images/")
	form = agent.page.forms.first
	form.username = 'tifosifiles'
	form.password = 'tifosi1'
	form.submit
	agent.page.link_with(:text => "Click here if you are not redirected automatically").click
	agent.page.link_with(:text => "2011 Dealer Info and Pics").click
	agent.page.link_with(:text => "2011 Product Images").click
	@links = agent.page.search('#Downloads a')
	@links.each do |link|
		link_url = link['href']
		pieces = link_url.split(/[\/.]/)
		product = pieces[pieces.count-2].split(/ /).first
		sku = pieces[pieces.count-2].split(/ /).last
		puts product + ":" + sku
	end
	
	agent.get("http://www.tifosioptics.com/files/2011%20Dealer%20Info%20and%20Pics/2011%20Product%20Images/")
	agent.page.link_with(:text => "2012 Lineup").click
	
	# csv upload for product stuff - overwrite dups
	
	# for each image, look up by SKU, flag those that don't match (or log them?)
	# use paperclip to add an image to the database for that product
	# push product to amazon
	# push product to shopify
	# push product to ordermotion
	
end


