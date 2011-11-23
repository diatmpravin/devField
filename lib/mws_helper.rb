class MwsHelper
	
	def self.instance_vars_to_hash(obj)
			obj_hash = {}
			obj.instance_variable_names.each do |n|
				m = n.sub('@','')
				if m != 'roxml_references' && m!= 'promotion_ids'
					obj_hash[m.to_sym] = obj.instance_variable_get(n)
				end
			end
			return obj_hash
	end
	
end