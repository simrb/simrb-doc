configure :production do
	not_found do
		Sl['sorry, no page']
	end

	error do
		Sl['sorry there was a nasty error - '] + env['sinatra.error'].name
	end
end

before do
	_base
end

#set the default page
get '/' do
#  	pass if request.path_info == '/'
	status, headers, body = call! env.merge("PATH_INFO" => _var(:home, :link))
end

get '/_index' do
	_tpl :_index
end

get "/robots.txt" do
	arr = [
		"User-agent:*",
		"Disallow:/_*",
	]
	arr.join("\n")
end

helpers do

	def _base
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

	#return a random string with the size given
	def _random size = 12
		charset = ('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a
		(0...size).map{ charset.to_a[rand(charset.size)]}.join
	end

	def _ip
		ENV['REMOTE_ADDR'] || '127.0.0.1'
	end

end
