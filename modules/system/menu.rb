helpers do

	# get a hash menu by tag
	#
	# == Examples
	#
	#	_menu :admin
	#
	# return an array, like this
	#
	#	[
	#		{:name => 'name', :link => 'link'},
	#		{:name => 'name', :link => 'link', :focus => true},
	#		{:name => 'name', :link => 'link', :sub_menu => [{:name => 'name', :link => 'link'},{},{}]},
	# 	]
	#
	def _menu tag, menu_level = 2, set_tpl = true
		ds = Sdb[:_menu].filter(:mid => _tag_ids(:_menu, tag)).order(:order)
		return [] if ds.empty?

		arr_by_parent	= {}
		arr_by_mid		= {}

		ds.each do | row |
			arr_by_mid[row[:mid]] = row
			arr_by_parent[row[:parent]] ||= []
			arr_by_parent[row[:parent]] << row[:mid] 
		end

		data = []

		# 1-level menu
		arr_by_parent[0].each do | mid |
			menu1 = {}
			menu1[:name] = arr_by_mid[mid][:name]
			menu1[:link] = arr_by_mid[mid][:link]
			# mark the current menu
			if request.path == arr_by_mid[mid][:link]
				menu1[:focus] = true 
				# input the title, keywords, descrptions for template page
				if set_tpl
					@t[:title] = arr_by_mid[mid][:name]
					@t[:keywords] = arr_by_mid[mid][:name]
					@t[:description] = arr_by_mid[mid][:description]
				end
			end

			# 2-level menu
			if arr_by_parent.has_key? mid
				menu1[:sub_menu] = []
				arr_by_parent[mid].each do | num |
					menu2 = {}
					menu2[:name] = arr_by_mid[num][:name]
					menu2[:link] = arr_by_mid[num][:link]
					# mark the current menu
					if request.path == arr_by_mid[num][:link]
						menu1[:focus] = true 
						menu2[:focus] = true 
						# input the title, keywords, descrptions for template page
						if set_tpl
							@t[:title] = arr_by_mid[num][:name]
							@t[:keywords] = arr_by_mid[num][:name]
							@t[:description] = arr_by_mid[num][:description]
						end
					end
					menu1[:sub_menu] << menu2
				end
			end

			data << menu1
		end

		data
	end

	# add menu
	#
	# == Example
	#
	#	_menu_add({:name => 'menu1', :link => 'link1', :tag => 'top_menu'})
	#
	#	or,
	#
	#	_menu_add({:name => 'menu3', :link => 'link3', parent => 'menu1', tag => 'top_menu'})
	#
	def _menu_add data = {}
		unless data.empty?
			if data.include? :parent
				ds = Sdb[:_menu].filter(:name => data[:parent])
				data[:parent] = ds.get(:mid) unless ds.empty?
			end
 			_submit :_menu, :fkv => data, :uniq => true
# 			Sdb[:menu].insert(data)
		end
	end

end

