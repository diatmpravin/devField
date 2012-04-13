source 'http://rubygems.org'
gem 'rails', '3.1.3'
#gem 'rails', '3.2.2' #TODO bump rails version

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'
gem 'paperclip', "~>2.4.5"
gem 'aws-s3', :require => 'aws/s3'
#gem 'aws-sdk'		#TODO new version for paperclip, bump to paperclip 3.0, deal with consequences
gem 'kaminari'	# pagination



group :development, :test do
	gem 'heroku'
	gem 'factory_girl_rails'
	gem 'mocha'
	gem 'watir-webdriver'
end

gem 'amazon-mws', :git => 'git://github.com/aew/amazon-mws.git'
gem 'RubyOmx', :git => 'git://github.com/aew/RubyOmx.git'

gem 'pg'
gem 'ruby-hmac'
gem 'roxml'
gem 'haml'
gem 'shopify_app'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
end

gem 'jquery-rails'


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
	gem 'turn', '0.8.2',:require => false	# Pretty printed test output
	gem 'simplecov', :require => false
	#gem 'rspec-rails'
	#gem 'shoulda'
	#gem 'fakeweb'  
end
