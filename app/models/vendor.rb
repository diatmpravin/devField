#require 'RMagick'
#include Magick

# find a way to slow this down so it doesn't time out, OR CATCH TIMEOUT EXCEPTION AND SLEEP THEN RESTART
# find a way to have it pick up where it left off - remember what page it was on, or continue flipping until finding the last product
# capture the chip images as well
# consider capturing properties like frame material, eye shape, rim type, etc

class Vendor < ActiveRecord::Base
	has_many :brands, :dependent => :destroy
	has_many :products, :through => :brands
	has_attached_file :icon, PAPERCLIP_STORAGE_OPTIONS.merge({:path => "/:class/:attachment/:id/:style/:filename"})
	validates_uniqueness_of :name

=begin
	BASE_URL = "http://www.mysafilo.com/"
	BASE_WIDTH = 400
	ZOOM_WIDTH = 320
	SLEEP_AFTER_ITEM = 3
	GET_IMAGES = 1
	
	@agent = nil
	attr_reader :agent
=end

	# Remove all products (permanently) from each brand under this vendor (presumably in prep for a new scrape)
	def clear_products
		self.brands.each do |b|
			b.products.each do |p| 
				p.destroy
			end
		end
	end

=begin	
	def login
		#TODO need to generalize this somehow, but how?
		self.scraped_at = Time.now
		@agent = Mechanize.new
		@agent.get(self.login_url) #BASE_URL+"pub/") #login_url
		if self.name == 'Safilo'
			form = @agent.page.forms.first #form_number
			form.username = self.username #'125616500'
			form.password = self.password #'6m4gyeqj'
			form.submit
			@agent.page.link_with(:text => "Our Brands").click #brand nexus url
		elsif self.name == 'Oakley'
			form = @agent.page.forms.first #form_number
			form.UserId = self.username #'19066'
			form.nolog_password = self.password #'hdosport1'
			form.submit
		elsif self.name == 'Luxottica'
			@agent = Watir::Browser
			form = @agent.page.form(:name=>'Logon')
			form.logonId = self.username
			form.logonPassword = self.password
			@agent.page.link_with(:text => 'Catalog').click
			
			
		end
	end
	
	def process_brands
		login
		brand_nexus_url = @agent.page.uri
		self.brands.each do |b|
			process_brand(b)
			@agent.get(brand_nexus_url)	
		end
	end
	
	def process_brand(b)
		if self.name == 'Safilo'
			@agent.page.link_with(:text => b.name).click #link better be the brand name
			@agent.page.link_with(:text => "View Collection").click # safilo specific...
		elsif self.name == 'Oakley'
		
		end
		
		process_items_page(b)		
	end

	def process_items_page(brand)
		i = 0
		current_page = @agent.page
		next_link = current_page.link_with(:text => "Next")
		while !next_link.nil?
			if i>0
				current_page = next_link.click
			end
			i +=1
			links = current_page.search(".styleNameCell a")
			
			links.each do |link|
				if !link['href'].nil?
					process_item(brand,link)
				end
			end
					
			next_link = current_page.link_with(:text => "Next")
			#next_link = nil
		end			
	end
	
	def process_item(brand, link)
		product = link.text.strip
		sku = link['href'].split(/styleNumber=/)[1].strip
						
		# insert or update the base product into products
		p = Product.find_or_create_by_brand_id_and_base_sku(brand.id, sku)
		updated = p.updated_at
		if (updated.nil? || updated <= self.scraped_at)
			p.name = product	
		
			sub_page = @agent.get(link['href'])
			criteria_array = sub_page.search("#moreLikeThis input[type='checkbox']")
			criteria_string = ""
			criteria_array.each do |c|
				criteria_string += "#{c['id']}:#{c['criterionvalue']},"
			end
			puts criteria_string
			p.meta_keywords = criteria_string			
			p.save!

			process_item_variants(p, sub_page)
			if GET_IMAGES == 1
				process_item_variant_images(p, sub_page)
			end
		end
		sleep SLEEP_AFTER_ITEM		
	end
	
	def process_item_variants(product, page)
		rows = page.search("#orderGrid tr")
		for j in 2..(rows.count-2)
			sku = "#{product.base_sku}-#{rows[j]['colorcode']}-#{rows[j]['lenscode']}"
			variant = Variant.find_or_create_by_product_id_and_sku(product.id, sku)
			process_variant(variant, rows[j])
			j += 1
		end	
	end
	
	def process_variant(variant, row)
		upc = row['title'].split(/:/)[1].strip
		color_code = row['colorcode']
		lens_code = row['lenscode']
		colorname = row['colorname']
					
		cols = row.children
		title = cols[0].text.split(/\(/)				
		#colorname = title[0].strip
		lens = title[1].sub(/\)/,'')
		lens = lens.sub(lens_code,'').strip
				
		variant.update_attributes({ :upc => upc,
										:color1_code => color_code,
										:color1 => colorname,
										:color2 => lens,
										:color2_code => lens_code,
										:size => cols[2].children[0].text,
										:cost_price => cols[4].children[0].text,
										:availability => cols[8].children[0].text,
										:is_master => false }) #TODO update whether it is the master or not
	end

	def process_item_variant_images(product, page)
		image_list = page.search("td.chipPicture")
		image_list.each do |img|
			sku = "#{product.base_sku}-#{img['colorcode']}-#{img['lenscode']}"
			variant = Variant.find_by_sku(sku)
			process_item_variant_image(variant, img, BASE_WIDTH ,'colorfcpicture')
			process_item_variant_image(variant, img, ZOOM_WIDTH ,'colorbigpicture')
		end
	end
	
	def process_item_variant_image(variant, img, width, chip_group)
			url_array = img[chip_group].split(/"><img src=\"/)
			url_array.shift
			if url_array.count==0
				return
			end
			url_array.last.sub!(/\"><\/div>/, '')
	
			cum_width = 0
			row_list = ImageList.new
			col_list = ImageList.new
			url_array.each do |u|
				begin
					chip = ImageList.new(BASE_URL + u)
				
				if ((cum_width + chip[0].columns) > width)		
					col_list << row_list.append(false) # concat the other ones that are in the row
					row_list = ImageList.new # start a new row					
					row_list << chip[0]
					cum_width = chip[0].columns
				else
					cum_width += chip[0].columns
					row_list << chip[0]		
				end
				
				rescue
					puts "error, moving on"				 
				end				
			end
			if row_list.count>0
				col_list << row_list.append(false)
			end
			if col_list.count>0
				combo_img = col_list.append(true)
				filename = "#{variant.product.brand.name}_#{variant.sku}_#{variant.color1}_#{width}.jpg"
				filename.gsub!(/\//,'-')
				filename.gsub!(/ /,'_')
				
				vi = VariantImage.find_or_create_by_variant_id_and_unique_image_file_name(variant.id, filename)
				if !vi.image.file?
					file = Paperclip::Tempfile.new(filename)
					combo_img.write(file.path)
					#vi.image_content_type = combo_img.mime_type
					#vi.image_file_size = combo_img.filesize
					#vi.image_width = combo_img.columns
					vi.image = file
					vi.image.save
					
					vi.save!
				end
			end
	end
=end
	
end