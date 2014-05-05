# ================================================
# assets resource
# ================================================
#/css/modulename/filename => the real path as 'modules/modulename/css/filename'
get '/_assets/:module/:filename' do
	path = Sdir + "modules/#{params[:module]}/#{Sbase::Dir[:assets]}/#{params[:filename]}"
	send_file path, :type => params[:filename].split('.').last().to_sym
end

# require 'sass'
# configure do
# 	set :sass, :cache => true, :cahce_location => './tmp/sass-cache', :style => :compressed
# end
# 
# get '/css/sass.css' do
# 	sass :index
# end

helpers do

	def _public path, domain = nil
		path
	end

	def _file path, domain = nil
		"/_file/get/#{path}"
	end

	def _assets path, domain = nil
		"/_assets#{path}"
	end

end


# ================================================
# helpers library
# ================================================

helpers do

	def _init_base
		# request query_string
		@qs	= {}

		# template common variable
		@t = {}

		# a key-val field that will be inserted to database
		@f = {}

  		#env["rack.request.query_hash"]
		_fill_qs_with request.query_string if request.query_string

		# message variable
		@msg = ''
		unless request.cookies['msg'] == ''
			@msg = request.cookies['msg'] 
			response.set_cookie 'msg', :value => '', :path => '/'
		end
	end

	def _fill_qs_with str
		str.split("&").each do | item |
			key, val = item.split "="
			if val and val.index '+'
				@qs[key.to_sym] = val.gsub(/[+]/, ' ')
			else
				@qs[key.to_sym] = val
			end
		end
	end

	# throw out the message, and redirect back
	def _throw str
		response.set_cookie 'msg', :value => str, :path => '/'
		redirect back
	end

	#set the message if get a parameter, otherwise returns the @str value
	def _msg str = ''
		@msg = str
		response.set_cookie 'msg', :value => str, :path => '/'
	end

	#load the template
	def _tpl tpl_name, layout = false
		slim tpl_name, :layout => layout
	end

	#get two columns of database table as a key-value hash
	def _kv table, key, value
		name = "#{table}-#{key}-#{value}".to_sym
		@cache ||= {}
		unless @cache.has_key? name
			@cache[name] = DB[table].to_hash(key, value)
		end
		@cache[name]
	end

	#return a random string with the size given
	def _random_string size = 12
		charset = ('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a
		(0...size).map{ charset.to_a[rand(charset.size)]}.join
	end

	def _ip
		ENV['REMOTE_ADDR'] || '127.0.0.1'
	end

	# ##########################
	# 		variable
	# ##########################
	# return a string, others is nil
	def _var key, tag = ''
		h 	= {:vkey => key.to_s}
		ds 	= DB[:_vars].filter(h)

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
 		DB[:_vars].filter(:vkey => key.to_s).update(:vval => val.to_s, :changed => Time.now)
#  		_submit(:name => :_vars, :fkv => argv, :opt => :update) unless argv.empty?
	end

	def _var_add argv = {}
 		_submit(:name => :_vars, :fkv => argv, :uniq => true) unless argv.empty?
	end

	# return current path, and with options
	#
	# == Examples
	#
	# assume current request path is /cms/user
	#
	# 	_url() # retuen '/cms/user'
	#
	# or give a path
	#
	# 	_url('/cms/home') # return '/cms/home'
	#
	# and, with some parameters
	#
	# 	_url('/cms/home', :uid => 1, :tag => 2) # return '/cms/home?uid=1&tag=2'
	#
	def _url path = request.path, options = {}
		str = path
		unless options.empty?
			str += '?'
			options.each do | k, v |
				str = str + k.to_s + '=' + v.to_s + '&'
			end
		end
		str
	end

	# it likes _url, but appends the @qs for options
	def _url2 path = '', options = {}
		@qs.merge!(options) unless options.empty?
		_url path, @qs
	end

	# ##########################
	# 			menu
	# ##########################
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
	def _menu tag, menu_level = 2, set_tpl = true
		ds = DB[:_menu].filter(:mid => _tag_ids(:_menu, tag)).order(:order)
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
					@t[:description] = arr_by_mid[mid][:descpt]
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
							@t[:description] = arr_by_mid[num][:descpt]
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
				ds = DB[:_menu].filter(:name => data[:parent])
				data[:parent] = ds.get(:mid) unless ds.empty?
			end
 			_submit :name => :_menu, :fkv => data, :uniq => true
# 			DB[:menu].insert(data)
		end
	end

	# == Examples
	#
	# puts the code to template
	#
	# 	== __nav(:nav_name, [:option1, :option2])
	#
	# returns
	# 	
	# 	<div class="nav_name">
	# 		<a href="/current_path?nav_name=option1" >option1</a>
	# 		<a href="/current_path?nav_name=option2" >option2</a>
	# 	</div>
	#
	def __nav name, options = []
		str = ""
		unless @nav_style
			str << '<link href="/css/nav-1.css" rel="stylesheet" type="text/css">'
			 @nav_style = true
		end
		options.each do | ot |
			if @qs[name] == ot.to_s
				str << "<a class='focus' href='" + _url2('', name => ot) + "'>" + L[ot] + "</a>"
			else
				str << "<a href='" + _url2('', name => ot) + "'>" + L[ot] + "</a>"
			end
		end
		str = "<div class='nav'>" + str + "</div>"
	end

	# ##########################
	# 		control system
	# ##########################
	# log the user operation by ip that refuses to do again at a period of time
	def _log? name, timeout, msg = ''
		reval = false
		ds = DB[:_logs].filter(:name => name.to_s, :ip => _ip)

		# if no record, create one
		if ds.empty?
			_submit :name => :_logs, :fkv => {:name => name.to_s}
		else
			# if timeout to the last log, update the changed time
			if _timeout?(ds.get(:changed), timeout)
				ds.update(:changed => Time.now)
			else
				reval = true
				_throw msg if msg != ''
			end
		end

		reval
	end

	# control the number of action by ip in a period of time
	def _mark?
	end

end

