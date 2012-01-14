require 'test_helper'

class StateTest < ActiveSupport::TestCase

  test "raw state should be upper case and unique" do
  	
		s = Factory(:state)
		
		# duplicate name	
		assert_difference('Store.count',0) do
			State.create(s.attributes)
		end
		
		# new and unique name, capitalized
		assert_difference('State.count',1) do
			s.raw_state = "unique state name"
			s2 = State.create(s.attributes)
			assert_equal s2.raw_state, 'UNIQUE STATE NAME'
		end
		
	end
 
end
