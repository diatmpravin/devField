source 'http://rubygems.org'

gem 'rails', '3.1.1'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'
gem 'paperclip'
gem 'heroku'
gem 'aws-s3', :require => 'aws/s3'

group :production do
	gem 'pg'
end

group :development, :test do
	gem 'sqlite3'
	gem 'ruby-debug-base19', "0.11.24"
	gem 'ruby-debug19', "0.11.6"
end

#gem 'amazon-mws', :path => "/Ruby/fieldday/amazon-mws"
gem 'amazon-mws', :git => 'git://github.com/adamwible/amazon-mws.git'
gem 'mechanize'

#gem 'jeweler'
gem 'ruby-hmac'
gem 'roxml'
gem 'haml'
gem 'slowweb'
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
  gem 'turn', :require => false
end
