# ================================================
# file system
# ================================================
before '/_file/*' do
	#set the level
	if request.path == '/_file/upload'
		_level? _var(:upload_level, :file)
	end
end

#upload file
post '/_file/upload' do
	if params[:upload] and params[:upload][:tempfile] and params[:upload][:filename]
		_file_save params[:upload]
		L[:'upload complete']
	else
		L[:'the file is null']
	end
end

#get file list by type
get '/_file/type/:type' do
	page_size = 20
	page_curr = (@qs.include?(:page_curr) and @qs[:page_curr].to_i > 0) ? @qs[:page_curr].to_i : 1

	#search condition
	ds = DB[:_file].filter(:uid => _user[:uid])
	if params[:type] == 'all'
	elsif params[:type] == 'image'
		ds = ds.where(Sequel.like(:type, "#{params[:type]}/%"))
	end

	unless ds.empty?
		ds = ds.select(:fid, :name, :type).reverse_order(:fid)
		Sequel.extension :pagination
		result = ds.paginate(page_curr, page_size, ds.count)
		page_count = result.page_count

		page_prev = (page_curr > 1 and page_curr <= page_count) ? (page_curr - 1) : 0
		page_next = (page_curr > 0 and page_curr < page_count) ? (page_curr + 1) : 0

		res = result.all
		res.unshift({:prev => page_prev, :next => page_next, :size => page_count, :curr => page_curr})

		require 'json'
		JSON.pretty_generate res
	else
		nil
	end
end

#get the file by id
get '/_file/get/:fid' do
	fid = params[:fid].to_i
	ds = DB[:_file].filter(:fid => fid)
	unless ds.empty?
		send_file Scfg[:upload_dir] + ds.get(:path).to_s, :type => ds.get(:type).split('/').last.to_sym
	else
		send_file Sdir + 'public/images/default.jpg', :type => :jpeg
	end
end

helpers do
	
	# save file info to db, and move the file content to upload directory
	#
	# == Arguments
	# file, 		filename, tempfile
	# returned, 	return file info by the symbol you pass
	def _file_save file, returned = nil
		fields = {}
		fields[:uid] 		= _user[:uid]
		fields[:name] 		= file[:filename].split('.').first
		fields[:created]	= Time.now
		fields[:type]		= file[:type]
		fields[:path] 		= "#{_user[:uid]}-#{fields[:created].to_i}#{_random_string(3)}"

		#validate file specification
		unless _var(:filetype, :file).include? file[:type]
			_throw L[:'the file type is wrong']
		end
		file_content = file[:tempfile].read
		if (fields[:size] = file_content.size) > _var(:filesize, :file).to_i
			_throw L[:'the file size is too big']
		end

		#save the info of file
		#table = file[:table] ? file[:table].to_sym : :file
		DB[:_file].insert(fields)

		#save the body of file
		File.open(Scfg[:upload_dir] + fields[:path], 'w+') do | f |
			f.write file_content
		end

		#return the value
		unless returned == nil
			DB[:_file].filter(fields).get(returned)
		end
	end

	def _file_rm fid, level = 1
		ds = DB[:_file].filter(:fid => fid.to_i)
		unless ds.empty?
			path 	= ds.get(:path)
			uid		= ds.get(:uid)

			#validate user
			unless uid.to_i == _user[:uid]
				_throw L[:'your level is too low'] if _user[:level] < level
			end

			#remove record
			ds.delete

			#remove file
			File.delete Scfg[:upload_dir] + path
		end
	end

	def _parser_init extension = {}
		require 'redcarpet'
		extensions = {:autolink => true, :space_after_headers => true}
		extensions.merge! extension
		@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions)
	end

	def _m2h str
		@markdown.render str
	end
end


