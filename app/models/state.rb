class State < ActiveRecord::Base
	validates_uniqueness_of :raw_state
	before_validation :upcase_state
	
	def upcase_state
		self.raw_state = self.raw_state.upcase
		self.clean_state = self.clean_state.upcase
	end
end
