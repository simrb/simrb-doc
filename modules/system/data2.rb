configure do
	Sdb = Sequel.connect(Scfg[:db_connection])
end

helpers do

	# get two columns of database table as a key-value hash
	def _kv table, key, value
		name = "#{table}-#{key}-#{value}".to_sym
		@cache ||= {}
		unless @cache.has_key? name
			@cache[name] = Sdb[table].to_hash(key, value)
		end
		@cache[name]
	end

	def _parser_init extension = {}
# 		require 'redcarpet'
# 		extensions 	= {:autolink => true, :space_after_headers => true}.merge(extension)
# 		html_obj 	= Redcarpet::Render::HTMSl.new()
# 		@markdown 	= Redcarpet::Markdown.new(html_obj, extensions)

		@markdown_extensions = extension
# 		require 'rdiscount'

  		require 'kramdown'

	end

	def _m2h str
# 		# redcarpet
#   	@markdown.render str

#  		# rdiscount
#  		RDiscount.new(str).to_html

		# kramdown
  		Kramdown::Document.new(str, @markdown_extensions).to_html
	end

	#submit data
	def _submit name, argv = {}
		t 				= _init_t(argv.merge(name: name))
		opt 			= argv[:opt] == nil ? :insert : :update
		t[:tag]			= t.include?(:tag) ? t[:tag] : true
		t[:valid]		= t.include?(:valid) ? t[:valid] : true

		# default event is updated , if the primary_key has been given.
		if @qs.include?(t[:pk])
			t[:conditions][t[:pk]] = @qs[t[:pk]].to_i
			opt = :update
		end

		# extract the tag value, if the tag field would be submit
		tag	= t[:fkv].delete(:tag) if t[:fkv].include?(:tag)
		tag	= params[:tag] if params[:tag]

		# insert data
		if opt == :insert
			f	= _set_f t[:fkv], t[:fields]
			f	= t[:fkv].merge(f)
			_valid t[:name], f if t[:valid] == true
# 			@f[:created] = Time.now if @f.include? :created
			f.delete t[:pk]

			# check the data whether it exists in db
			if t.include?(:uniq) and t[:uniq] == true
				ds = Sdb[t[:name]].filter(f)
				Sdb[t[:name]].insert(f) if ds.empty?
			else
				Sdb[t[:name]].insert(f)
			end
			pkid = Sdb[t[:name]].filter(f).limit(1).get(t[:pk])

		# update data
		else
			#tag	= f.delete(:tag) if f.include?(:tag) 
			ds = Sdb[t[:name]].filter(t[:conditions])
			unless ds.empty?
				f = _set_f ds.first, t[:fields]
				_valid t[:name], f if t[:valid] == true
				f.delete t[:pk]
				Sdb[t[:name]].filter(t[:conditions]).update(f)
				pkid = ds.get(t[:pk])
			else
				_throw Sl[:'no record in database']
			end
		end

		# insert or update the tag
		if t[:tag] == true and tag and _tag_enable?(t[:name])
			if opt == :insert
				_tag_add t[:name], pkid, tag
			else
				_tag_set t[:name], pkid, tag, params[:oldtag]
			end
		end
	end

	#remove record
	def _rm_ argv = {}
		t = _init_t argv
		@t[:repath] ||= (params[:_repath] || request.path)

		if params[t[:pk]]
			#delete one morn records
			if params[t[:pk]].class.to_s == 'Array'
				Sdb[t[:name]].where(t[:pk] => params[t[:pk]]).delete
			#delete single record
			else
				t[:conditions][t[:pk]] = params[t[:pk]].to_i 
				Sdb[t[:name]].filter(t[:conditions]).delete
			end
			#_msg Sl[:'delete complete']
		end
	end

	# set field values for variable @f
	# @f is a key-val hash of field that would be submit to db
	#
	# == Arguments
	# data,   a key-value hash that stores field name and value
	# fields, specify some fields to assign value
	def _set_f data, fields
		res = {}
		fields.each do | k |
			if params[k]
				res[k] = params[k]
			elsif @qs.include? k
				res[k] = @qs[k]
			elsif data.include? k
				res[k] = data[k]
			else
				res[k] = ''
			end

			#specify field, fill the value, auto
			if k == :changed
				res[k] = Time.now
			end
		end
		res
	end

	def _valid name, f
		Svalid[name].map { |b| instance_exec(f, &b) } if Svalid[name]
	end

	def _data name
		Sdata[name].map { |b| instance_eval(&b) }.inject(:merge) if Sdata[name]
	end

	# set the form_type of field for template, 
	# and return data block, fields, primary_key, kv
	#
	# == Returned
	# table/data block defined schema
	# all of field names
	# primary_key of field
	# key-value of field
	#
	# == Example
	#
	# 	_schema :user
	#
	# output
	# 
	# {
	# 	:data => {:uid => {:default => 0, :type => 'Fixnum' ,,,}, :name => {:default => '', ,,,}}, 
	# 	:fields => [:uid, :name, :pawd, :level ,,,],
	# 	:pk => :uid, 
	# 	:fkv => {:uid => 0, :name => '', :pawd => '123456' ,,,}
	# }
	def _schema name
		#wait to build cache
		pk 		= nil
		fields 	= []
		fkv		= {}
		data 	= _data_format name

# 		schema = Sdb.schema name.to_sym
		data.each do | field, val |
			# save primary_key
			pk = field if val[:primary_key] == true

			# a key-val hash
			fkv[field] = val[:default]

			# default form type
			unless val.include? :form_type
				if val.include? :assoc_one
					val[:form_type] = :radio 
				elsif val.include? :assoc_many
					val[:form_type] = :checkbox 
				elsif Scfg[:number_types].include? val[:type]
					val[:form_type] = :number 
				elsif val[:type] == 'Text'
					val[:form_type] = :textarea 
				elsif field == :changed or field == :created
					val[:form_type] = :hide
				else
					val[:form_type] = :text
				end
			end

			# all of fields
			fields << field
		end
		{ :data => data, :fields => fields, :pk => pk, :fkv => fkv }
	end

	# get the data block by name, and set the default type and value of field
	def _data_format name, merge_data = nil
		data = _data name.to_sym
		data.each do | key, val |
			# default field type, and field value
			unless val.include? :type
				# fisrt, judge by default value
				if val.include? :default
					val[:type] = val[:default].class.to_s

				# second, judge by assoc_one, or assoc_many, or primary_key
				elsif val.include?(:assoc_one) or val.include?(:assoc_many) or val.include?(:primary_key)
					val[:type] = Scfg[:number_types][0]
					val[:default] = 1

				# others, matches by field name
				else
					val[:type] = _match_field_type key
					val[:default] = ''
				end
			end

			# default value of field
			unless val.include? :default
				if val.include? :type
					if Scfg[:number_types].include? val[:type]
						val[:default] = 1
					end
				end
			end
			val[:default] = '' unless val.include? :default
		end
	end

	# judge the field type by field name, automatically 
	def _match_field_type field
		field = field.to_s
		if field[-2,2] == 'id'
			type = Scfg[:number_types][0]
		elsif Scfg[:fixnum_types].include? field
			type = 'Fixnum'
		elsif Scfg[:time_types].include? field
			type = 'Time'
		else
			type = 'String'
		end
		type
	end

end
