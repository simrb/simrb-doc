helpers do

	# has it enable the tag function
	#
	# == Example
	#
	#	asking the post whether it enables the tag
	#
	# 	_tag_enable? :posts
	#
	def _tag_enable? name
		name 			= name.to_s
		tag_key			= 'TagsForTables'
		tag_disable 	= _var2(:tags_disable)
		reval			= false

		# if current tag is not disable, do it
		unless tag_disable.include? name
			tags = _var2(tag_key)

			# the first time access the enabled tag key, create it
			if tags.empty?
 				_var_add({:vkey => tag_key})
 				tags = _var2(tag_key)
			end

			# not current tag, create it
			unless tags.index(name)
				tags << name
 				_var_set(tag_key, tags.join(','))
			end
			reval = true
		end

		reval
	end

	# tag name convert to tag id
	#
	# == Example
	# 	
	# 	assuming the number 2 is a tid value of ruby tag
	#
	# 	_tag(:ruby) # => 2
	#
	def _tag name
		name = name.to_s.strip
		ds = DB[:_tags].filter(:name => name)
		if ds.empty?
			DB[:_tags].insert(:name => name) 
			DB[:_tags].filter(:name => name).get(:tid)
		else
			ds.get(:tid)
		end
	end

	# as the _tag, but return an array
	def _tag2 tag
		sign = ','
		tags = []
		if tag.class.to_s == 'Symbol'
			tags << tag.to_s 
		elsif tag.class.to_s == 'String'
			tags = tag.split(sign)
		elsif tag.class.to_s == 'Array'
			tags = tag
		end

		res = []
		tags.each do | tag |
			res << _tag(tag)
		end
		res
	end

	# Dose it already exsit the tags in db, return true, others false
	#
	# == Example
	#
	# 	judge the whether it has the tag existed
	#
	def _tags? assoc_table, assoc_id = nil
		DB[:_atag].filter(:assoc_table => _tag(assoc_table)).empty?
	end

	# get associated ids by table and tag
	#
	# == Example
	#
	#	get post ids by tag ruby
	#
	# 	_tag_ids(:posts, :ruby) # => [2, 3, 5, 6]
	#
	def _tag_ids assoc_table, tag
		h 		= {:assoc_table => _tag(assoc_table)}
		tags 	= _tag2 tag
		h[:tid] = tags unless tags.empty?
		DB[:_atag].filter(h).map(:assoc_id)
	end

	# get tag names
	#
	# == Example
	#
	#	get all of tags of a post by post id
	#
	# 	_tag_names(:posts, :pid, '')	# 'php, ruby, python'
	#
	def _tag_names assoc_table, assoc_id, reval = :html
		res = []
		ds 	= DB[:_atag].filter(:assoc_table => _tag(assoc_table), :assoc_id => assoc_id).map(:tid)

		unless ds.empty?
			ds = DB[:_tags].filter(:tid => ds)
			unless ds.empty?
				if reval == :html
					ds.each do | r |
						# reval is html
						res << "<a href='#{_url2('', :_tag => r[:name])}'>#{r[:name]}</a>"
	# 					res << r[:name]
					end
				else
					res = ds.map(:name)
				end
			end
		end

		res.empty? ? '' : res.join(' , ')
	end

	# get all of tags, return a hash
	#
	# == Example
	#
	# 	get all of tags of post
	#
	# 	_tag_hash(:posts)	# => { 1 => 'ruby', 2 => 'python',,, }
	#
	def _tag_hash assoc_table
		tids = DB[:_atag].filter(:assoc_table => _tag(assoc_table)).map(:tid)
		unless tids.empty?
			ds = DB[:_tags].filter(:tid => tids).to_hash(:tid, :name)
		end
	end

	# add tags
	#
	# == Example
	#	
	#	_tag_add(:vars, :vid, 'php, ruby, python')
	#
	def _tag_add assoc_table, assoc_id, tag
		tids = _tag2 tag
		tids.each do | tid |
			DB[:_atag].insert(:assoc_table => _tag(assoc_table), :assoc_id => assoc_id, :tid => tid)
		end
	end

	# set the tag, one or more
	#
	# == Example
	#
	#	remove the tags for vars table by vid 1
	#
	#	_tag_set(:vars, 1, 'php, ruby, python', 'php, ruby')
	#
	#	or, add
	#
	#	_tag_set(:vars, 1, 'php, ruby', 'php, ruby, python')
	#
	def _tag_set assoc_table, assoc_id, cur_tag, org_tag
		cur_tag	= cur_tag.split(',').map { | m | m.strip }
		org_tag = org_tag.split(',').map { | m | m.strip }
		add_tag	= []
		rm_tag	= []

		unless org_tag.eql? cur_tag
			# add tag
			cur_tag.each do | tag |
				add_tag << tag unless org_tag.include?(tag)
			end

			# remove tag
			org_tag.each do | tag |
				rm_tag << tag unless cur_tag.include?(tag)
			end
		end

		unless add_tag.empty?
			_tag_add assoc_table, assoc_id, add_tag
		end

		unless rm_tag.empty?
			_tag_rm assoc_table, assoc_id, rm_tag
		end
	end

	# remove associated tags
	#
	# == Example
	# 
	# 	assuming we remove the post tag by a post id 1
	#
	# 	_tag_rm(:posts, 1, :ruby)
	#
	# 	or
	#
	# 	_tag_rm(:posts, 1, 'ruby, python')
	#
	# 	or
	#
	# 	_tag_rm(:posts, 1, [:ruby, :python])
	#
	def _tag_rm assoc_table, assoc_id, tag
		tids = _tag2 tag
		unless tids.empty?
			tids.each do | tid |
				DB[:_atag].filter(
					:assoc_table 	=> _tag(assoc_table),
					:assoc_id 		=> assoc_id,
					:tid 			=> tid
				).delete
			end
		end
	end

end

