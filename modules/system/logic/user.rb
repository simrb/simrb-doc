get '/l' do redirect _var(:login, :link) end
get '/_login' do
	redirect _var(:after_login, :link) if _user[:uid] > 0
	@qs[:come_from] = request.referer unless @qs.include?(:come_from) 
	user_page :_login
end

get '/_logout' do
	_logout
end

get '/_register' do
	if _var(:allow_register, :user) == 'yes'
		user_page :_register
	else
		redirect _var(:login, :link)
	end
end

post '/_login' do
	_login params
	return_page = @qs.include?(:come_from) ? @qs[:come_from] : _var(:after_login, :link)
	redirect return_page
end

post '/_register' do
	_user_add params if _var(:allow_register, :user) == 'yes'
	return_page = @qs.include?(:come_from) ? @qs[:come_from] : _var(:after_login, :link)
	redirect return_page
end

helpers do

	def user_page name
		_tpl name, :layout
	end

	# ========================================
	# user operation
	# ========================================

	# user login by user name and password
	def _login argv = nil
		if argv[:name] and argv[:pawd]

			# valid field format
			f = argv
			_valid :user, f

			# if no user
			ds = Sdb[:_user].filter(:name => f[:name])
			_throw Sl[:'the user is not existed'] if ds.empty?

			# verify password
			require "digest/sha1"
			if ds.get(:pawd) == Digest::SHA1.hexdigest(f[:pawd] + ds.get(:salt))
				sid = Digest::SHA1.hexdigest(f[:name] + Time.now.to_s)
				_session_create sid, ds.get(:uid)
			else
				_throw Sl[:'the password is wrong']
			end

		end
	end

	def _logout return_url = nil
		return_url ||= _var(:after_login, :link)
		sid = request.cookies['sid']

		# remove client cache
		response.set_cookie "sid", :value => "", :path => "/"

		# clear server cache
		_session_remove sid
		redirect _url2(return_url)
	end

	# check the current user whether or not login
	#
	# == Example
	#
	# if the user is unlogin status, that will be jump to the page '/loginpage'
	# 	
	# 	_login? _url('/loginpage')
	#
	# if the user has been login, that will return true, other is false.
	#
	# 	_login?
	def _login? redirect_url = nil
		islogin = _user[:uid] > 0 ? true : false
		if islogin
			_session_update _user[:sid], _user[:uid]
		else
			if redirect_url != nil and redirect_url != request.path
				@qs[:come_from] = request.path
				redirect _url2(redirect_url)
			end
		end
		islogin
	end

	# if the user level less than the given, raise a message
	def _level? level
		_throw Sl[:'your level is too low'] if _user[:level].to_i < level.to_i
	end

	#check the user by name , if it exists, return uid, others is nil
	def _user? name
		uid = Sdb[:_user].filter(:name => name).get(:uid)
		uid ? uid : nil
	end

	# get the current user infomation by uid,
	#
	# == Argument
	# uid, integer, default value is 0
	#
	# == Returned
	# a hash, the key have :uid, :name
	def _user uid = 0
		@infos 			= {}
		@infos[:uid] 	= uid
		@infos[:name] 	= 'unknown'
		@infos[:level] 	= 0
		@infos[:sid] 	= ''

		# get uid
		if uid == 0
			# checks the uid whether exists in session
			if sid = request.cookies['sid']
				uid = _session_has sid
			end
		end

		# fetch info by uid
		if uid.to_i > 0
			ds = Sdb[:_user].filter(:uid => uid)
			@infos[:uid]		= uid
			@infos[:name] 	= ds.get(:name)
			@infos[:level] 	= ds.get(:level)
			@infos[:sid] 	= sid
		end
		@infos
	end

	def _user_del uid
		Sdb[:_user].filter(:uid => uid.to_i).delete
		Sdb[:_sess].filter(:uid => uid.to_i).delete
	end

	def _user_edit_ argv = {}
		argv 		= params if params[:pawd] or params[:level]
		argv[:uid]	= @qs[:uid].to_i if @qs.include? :uid

		_valid :_user_edit, argv

		_throw Sl[:'no user id'] unless argv.include? :uid
		ds = Sdb[:_user].filter(:uid => argv[:uid])
		unless ds.empty?
			f = {}

			#password
			if argv[:pawd]
				f[:pawd] = Digest::SHA1.hexdigest(argv[:pawd] + ds.get(:salt))
			end

			#userlevel
			f[:level] = argv[:level] if argv[:level]
			Sdb[:_user].filter(:uid => argv[:uid]).update(f)
		end
	end

	# add a new user
	#
	# == Arguments
	# a hash includes :name, :pawd, :level
	#
	# == Returned
	# return uid, others is 0
	def _user_add argv = {}
		f				= {}
		f[:tag]			= argv[:tag] if argv.include?(:tag)
		f[:salt] 		= _random 5

		#username
		_throw Sl[:'the user is existing'] if _user? f[:name]
		f[:name] 		= argv[:name]

		#password
		require "digest/sha1"
		f[:pawd] 		= Digest::SHA1.hexdigest(argv[:pawd] + f[:salt])

# 		Sdb[:user].insert(f)
		_submit :_user, :fkv => f, :uniq => true
		uid = Sdb[:_user].filter(:name => f[:name]).get(:uid)
		uid ? uid : 0
	end


	# ========================================
	# rule operation
	# ========================================

	# asks the current user whether exists the rule name
	#
	# == Returned
	# it exists, return rule id, others is throw a msg
# 	def _rule? name
# 		uid = _user[:uid]
# 		ds = Sdb[:_rule].filter(:name => name.to_s)
# 		if rid = ds.get(:rid)
# 			unless Sdb[:_user2_rule].filter(:uid => uid, :rid => rid).empty?
# 				return rid
# 			end
# 		end
# 		_msg Sl[:'no rule for this operate']
# 		redirect _var(:home, :link)
# 	end

# 	def _rule_add argv = {}
#    		_submit :_rule, :fkv => argv, :uniq => true
# #   	Sdb[:_rule].insert(argv) unless argv.empty?
# 	end

	# add the rule for user
	#
	# == Arguments
	# rule, string, or array, the rule name, such as 'system', or ['system', 'admin']
	# user, string
# 	def _user_join rule, user
# 		if rule.class.to_s == 'Array'
# 			rule.each do | a |
# 				_user_join a, user
# 			end
# 		else
# 			rid = Sdb[:_rule].filter(:name => rule).get(:rid)
# 			uid = _user? user
# 			if rid > 0 and uid
# 				Sdb[:_user2_rule].insert(:uid => uid, :rid => rid)
# 			end
# 		end
# 	end

	# ========================================
	# user session
	# ========================================

	# == _session_update
	# update the session time by sid and uid, 
	#
	# == Argument
	# sid, string, the session id
	# uid, integer, the user id
	def _session_update sid = "", uid = 0
		ds = Sdb[:_sess].filter(:sid => sid, :uid => uid.to_i)
		ds.update(:changed => Time.now) if ds.count > 0
	end

	def _session_remove sid = nil
		Sdb[:_sess].filter(:sid => sid).delete if sid
	end

	def _session_clean_all_
		Sdb[:_sess].where('uid != ?', _user[:uid]).delete
	end

	def _session_clean_timeout_
		Sdb[:_sess].where('timeout = ?', 1).delete
	end

	def _session_create sid, uid
		# client cookie
		if params[:rememberme] == 'yes'
			# timeout class is day, default is 30 (days)
			timeout = _var(:timeout_of_session, :user).to_i
			response.set_cookie "sid", :value => sid, :path => "/", :expires => (Time.now + 3600*24*timeout)
		else
			timeout = 1
			response.set_cookie "sid", :value => sid, :path => "/"
		end

		# server
		Sdb[:_sess].insert(:sid => sid, :uid => uid, :changed => Time.now, :timeout => timeout, :ip => _ip)
	end

	# the user do nothing in the timeout, the session will be remove, automatically
	# return the uid
	def _session_has sid
		uid = 0
		ds 	= Sdb[:_sess].filter(:sid => sid)
		if ds.get(:sid)
			# remove the session, if timeout that is current time - login time of last
			current_time = Time.now
			changed_time = ds.get(:changed)
			days = (current_time.year - changed_time.year)*365 + current_time.yday - changed_time.yday
			if days > ds.get(:timeout).to_i
				ds.delete
			else
				uid = ds.get(:uid)
			end
		end
		uid
	end

	# == Arguments
	#
	# changed_time,	Time class
	# timeout, Integer, seconds
	#
	# == Examples
	#
	# 	start_time = Time.new - 31
	#
	#	# 1 day
	# 	_timeout?(start_time, 3600*24) 	# => false
	#
	#	# 30 seconds
	# 	_timeout?(start_time, 30) 		# => true
	def _timeout? changed_time, timeout
		@current_time ||= Time.now
		(@current_time - changed_time - timeout) > 0 ? true : false
	end

	# mark the operation by ip that prevents the same user do an action many times in specified time
	def _mark name, timeout, msg = ''
		reval = false
		ds = Sdb[:_mark].filter(:name => name.to_s, :ip => _ip)

		# if no record, create one
		if ds.empty?
			_submit :_mark, :fkv => {:name => name.to_s}
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

end


