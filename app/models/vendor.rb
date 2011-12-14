require 'RMagick'
include Magick

# find a way to slow this down so it doesn't time out
# find a way to have it pick up where it left off - remember what page it was on, or continue flipping until finding the last product
# capture the chip images as well
# consider capturing properties like frame material, eye shape, rim type, etc

class Vendor < ActiveRecord::Base
	has_many :brands, :dependent => :destroy
	validates_uniqueness_of :name

	BASE_URL = "http://www.mysafilo.com/"
	BASE_WIDTH = 400
	@agent = nil

	def login
		#TODO need to generalize this somehow, but how?
		@agent = Mechanize.new
		@agent.get(BASE_URL+"pub/")
		form = @agent.page.forms.first
		form.username = '125616500'
		form.password = '6m4gyeqj'
		form.submit
		@agent.page.link_with(:text => "Our Brands").click
	end
	
	def process_brands
		login
		brand_nexus_url = @agent.page.uri
		self.brands.each do |b|
			@agent.page.link_with(:text => b.name).click
			@agent.page.link_with(:text => "View Collection").click
			process_items_page(b)
			@agent.get(brand_nexus_url)	
		end
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
		#puts "#{brand.name}-#{product}:#{sku}"
		
		# insert or update the base product into products
		p = Product.find_or_create_by_brand_id_and_base_sku(brand.id, sku)
		p.name = product
		p.save!
		
		sub_page = @agent.get(link['href'])
		process_item_variants(p, sub_page)
		process_item_variant_images(p, sub_page)		
	end
	
	def process_item_variants(product, page)
		rows = page.search("#orderGrid tr")
		for j in 2..(rows.count-2)
			sku = "#{product.base_sku}-#{rows[j]['colorcode']}-#{rows[j]['lenscode']}"
			#TODO update whether it is the master or not
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
										:is_master => false })
	end

	def process_item_variant_images(product, page)
		image_list = page.search("td.chipPicture")
		image_list.each do |img|
			sku = "#{product.base_sku}-#{img['colorcode']}-#{img['lenscode']}"
			variant = Variant.find_by_sku(sku)
			process_item_variant_image(variant, img)
		end
	end
	
	def process_item_variant_image(variant, img)
			url_array = img['colorfcpicture'].split(/"><img src=\"/)
			url_array.shift
			if url_array.count==0
				return
			end
			url_array.last.sub!(/\"><\/div>/, '')
	
			cum_width = 0
			row_list = ImageList.new
			col_list = ImageList.new
			url_array.each do |u|
				chip = ImageList.new(BASE_URL + u)
				if ((cum_width + chip[0].columns) > BASE_WIDTH)		
					col_list << row_list.append(false) # concat the other ones that are in the row
					row_list = ImageList.new # start a new row					
					row_list << chip[0]
					cum_width = chip[0].columns
				else
					cum_width += chip[0].columns
					row_list << chip[0]		
				end
			end
			if row_list.count>0
				col_list << row_list.append(false)
			end
			if col_list.count>0
				combo_img = col_list.append(true)
				filename = "#{variant.product.brand.name}_#{variant.sku}_#{variant.color1}.jpg"
				filename.gsub!(/\//,'-')
				filename.gsub!(/ /,'_') 
				combo_img.write(filename)
				vi = VariantImage.find_or_create_by_variant_id_and_image_file_name_and_image_file_size(variant.id, filename, combo_img.filesize)
				vi.image_content_type = combo_img.mime_type
				vi.save!
			end
	end
	
end