# ================================================
# file system
# ================================================
before '/_file/*' do
	#set the level
	if request.path == '/_file/upload'
		_level? _var(:upload_level, :file)
	end
end

# assets resource
get '/_assets/*' do
	path_items 	= request.path.split('/')
	module_name	= path_items.shift(3)[2]
	path 		= "#{Spath[:module]}#{module_name}#{Spath[:assets]}#{path_items.join('/')}"

	send_file path, :type => request.path.split('.').last().to_sym
end

# require 'sass'
# configure do
# 	set :sass, :cache => true, :cahce_location => './tmp/sass-cache', :style => :compressed
# end
# 
# get '/css/sass.css' do
# 	sass :index
# end

#upload file
post '/_file/upload' do
	if params[:upload] and params[:upload][:tempfile] and params[:upload][:filename]
		_file_save params[:upload]
		Sl[:'upload complete']
	else
		Sl[:'the file is null']
	end
end

#get file list by type
get '/_file/type/:type' do
	page_size = 20
	page_curr = (@qs.include?(:page_curr) and @qs[:page_curr].to_i > 0) ? @qs[:page_curr].to_i : 1

	#search condition
	ds = Sdb[:_file].filter(:uid => _user[:uid])
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
	ds = Sdb[:_file].filter(:fid => fid)
	unless ds.empty?
		send_file Spath[:upload_dir] + ds.get(:path).to_s, :type => ds.get(:type).split('/').last.to_sym
	else
		send_file "#{Spath[:public]}images/default.jpg", :type => :jpeg
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
		fields[:path] 		= "#{_user[:uid]}-#{fields[:created].to_i}#{_random(3)}"

		#validate file specification
		unless _var(:filetype, :file).include? file[:type]
			_throw Sl[:'the file type is wrong']
		end
		file_content = file[:tempfile].read
		if (fields[:size] = file_content.size) > _var(:filesize, :file).to_i
			_throw Sl[:'the file size is too big']
		end

		#save the info of file
		#table = file[:table] ? file[:table].to_sym : :file
		Sdb[:_file].insert(fields)

		#save the body of file
		File.open(Spath[:upload_dir] + fields[:path], 'w+') do | f |
			f.write file_content
		end

		#return the value
		unless returned == nil
			Sdb[:_file].filter(fields).get(returned)
		end
	end

	def _file_rm fid, level = 1
		ds = Sdb[:_file].filter(:fid => fid.to_i)
		unless ds.empty?
			path 	= ds.get(:path)
			uid		= ds.get(:uid)

			#validate user
			unless uid.to_i == _user[:uid]
				_throw Sl[:'your level is too low'] if _user[:level] < level
			end

			#remove record
			ds.delete

			#remove file
			File.delete Spath[:upload_dir] + path
		end
	end

	# generate the assets url
	#
	# == Example
	#
	# 	_assets('system/css/style.css')
	# 	_assets('system/tags/README.md')
	#
	# 	_assets('system/admin.css')
	# 	_assets('system/admin.css', 'https//www.example.com')
	#
	def _assets path, domain = '/'
		"#{domain}_assets/#{path}"
	end

	def _file path, domain = '/'
		"#{domain}_file/get/#{path}"
	end

end


