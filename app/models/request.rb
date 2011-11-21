class Request < ActiveRecord::Base
	# can get the total time it took by looking at create timestamp - last timestamp in child response
	has_many :responses
end
