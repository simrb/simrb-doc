helpers do

	# return a string, others is null value
	#
	# == Arguments
	#
	# key, this is key name
	# tag, tag name
	# val, default value, that will return if no this key in database
	#
	# == Example
	#
	# 	_var :home_page
	# 	_var :home_page, 'www'
	# 	_var :home_page, 'www', '/home/page'
	#
	def _var key, tag = '', val = ''
		h 	= {:vkey => key.to_s}
		ds 	= Sdb[:_vars].filter(h)

		if tag != ''
			tids = _tag_ids(:_vars, tag)
 			ds = ds.filter(:vid => tids)
		end

		# adding if the variable hasn't existing in database
		if ds.empty?
			_var_add({vkey: key, tag: tag, vval: val})
			val
		else
			ds.get(:vval)
		end
	end

	# return an array as value, split by ","
	def _var2 key, tag = '', val = '', sign = ","
		val = _var key, tag, val
		val.to_s.split(sign)
	end

	# update variable, create one if it doesn't exist
	def _var_set key, val
 		Sdb[:_vars].filter(:vkey => key.to_s).update(:vval => val.to_s, :changed => Time.now)
#  		_submit(:_vars, :fkv => argv, :opt => :update) unless argv.empty?
	end

	def _var_add argv = {}
		argv[:vkey] = argv[:vkey].to_s
		argv[:vval] = argv[:vval].to_s
 		_submit(:_vars, :fkv => argv, :uniq => true) unless argv.empty?
	end

end
