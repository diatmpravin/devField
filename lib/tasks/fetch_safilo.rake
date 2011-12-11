desc "fetch safilo"
task :fetch_safilo => :environment do
	require 'mechanize'			
	agent = Mechanize.new
	agent.get("http://www.mysafilo.com/pub/")
	form = agent.page.forms.first
	form.username = '125616500'
	form.password = '6m4gyeqj'
	form.submit
	agent.page.link_with(:text => "Our Brands").click
	
	agent.page.link_with(:text => "Carrera").click
	current_page = agent.page.link_with(:text => "View Collection").click

	i = 0
	next_link = current_page.link_with(:text => "Next")
	while !next_link.nil?
		if i>0
			current_page = next_link.click
		end
		i +=1
		links = current_page.search(".styleNameCell a")
		links.each do |link|
			product = link.text.strip
			sub_page = agent.get(link['href'])
					
			rows = sub_page.search("#orderGrid tr")
			data_array = Array.new
			
			for j in 2..(rows.count-2)				
				cols = rows[j].children
				data_array << { :title => cols[0].text,
										:size => cols[2].children[0].text,
										:price => cols[4].children[0].text,
										:availability => cols[8].children[0].text }
				 
				#puts "#{product}: #{title}, #{size}, #{price}, #{availability}"
				j += 1
			end
			
			
			chipImages = sub_page.search("chipImages img:nth-child(1)")
			
			# click the first chip image
			chipImages.each do |c|
				#c.click how to click because this is a nokogiri element
				agent.page.
			end
			# then get the .splitImage
			#images = sub_page.search(".splitImage img")
			#fullImage img
			images = sub_page.search("#fullImage img")
			
			# otherwise, switch to the next product each time you encounter blank.gif
			
			j = -1
			for k in 0..(images.count-1)
				puts "k=#{k}"
				source = nil
				if !images[k].nil?
					source = images[k].attr('src')
				end
				
				if !source.nil? && source.index("blank.gif")
					j += 1
					puts "j=#{j}"
				elsif !source.nil? && source.index("thumb").nil?
					puts "#{data_array[j][:title]}: #{source}"
				end
				
			end
			#79ED3B961FFEEFA8AC822D38
		end
		#next_link = current_page.link_with(:text => "Next")
		next_link = nil
	end	
end


