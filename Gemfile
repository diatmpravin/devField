source 'http://rubygems.org'
gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'
gem 'paperclip'
gem 'aws-s3', :require => 'aws/s3'
#gem 'aws-sdk'		# new version for paperclip
#gem 'xml-simple'
gem 'kaminari'	# pagination

group :production do
	gem 'pg'
end

gem 'rmagick'

group :development, :test do
	gem 'sqlite3'
	gem 'ruby-debug-base19', "0.11.24"
	gem 'ruby-debug19', "0.11.6"
	gem 'heroku'
  #gem 'rspec-rails', '2.6.1'
end

#gem 'amazon-mws', :path => "/Ruby/fieldday/amazon-mws"
gem 'amazon-mws', :git => 'git://github.com/adamwible/amazon-mws.git'
gem 'mechanize'

#gem 'RubyOmx', :path => "/Ruby/fieldday/RubyOmx"
gem 'RubyOmx', :git => 'git://github.com/adamwible/RubyOmx.git'

#gem 'jeweler'
gem 'ruby-hmac'
gem 'roxml'
gem 'haml'
#gem 'slowweb'
gem 'shopify_app'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
#gem 'spree', '~> 0.70.3'
#gem 'spree', :git => 'git://github.com/spree/spree.git'
#group :production do
#	gem 'spree_heroku'
#end
#gem 'spree_rdr_theme', :git => 'git://github.com/spree/spree_rdr_theme.git'


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2',:require => false
end
