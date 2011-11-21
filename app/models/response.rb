class Response < ActiveRecord::Base
	has_many :orders
	belongs_to :request
end
