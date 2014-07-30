helpers do

	# return a string, others is nil
	def _var key, tag = ''
		h 	= {:vkey => key.to_s}
		ds 	= Sdb[:_vars].filter(h)

		if tag != ''
			tids = _tag_ids(:_vars, tag)
 			ds = ds.filter(:vid => tids)
		end
 		ds.empty? ? '' : ds.get(:vval)
	end

	# return an array as value, split by ","
	def _var2 key, tag = ''
		val = _var key, tag
		val.index(',') ? val.split(',') : (val == '' ? [] : [val])
	end

	# update variable, create one if it doesn't exist
	def _var_set key, val
 		Sdb[:_vars].filter(:vkey => key.to_s).update(:vval => val.to_s, :changed => Time.now)
#  		_submit(:_vars, :fkv => argv, :opt => :update) unless argv.empty?
	end

	def _var_add argv = {}
 		_submit(:_vars, :fkv => argv, :uniq => true) unless argv.empty?
	end

end
