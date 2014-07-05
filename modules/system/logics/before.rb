# default environment and db configuration setting
set :environment, Scfg[:environment].to_sym

configure do
	Sdb = Sequel.connect(Scfg[:db_connection])
end

configure :production do
	not_found do
		Sl['sorry, no page']
	end

	error do
		Sl['sorry there was a nasty error - '] + env['sinatra.error'].name
	end
end

# alter the path of template customized 
set :views, Spath[:view]
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

before do
	_init_base
end

#set the default page
get '/' do
#  	pass if request.path_info == '/'
	status, headers, body = call! env.merge("PATH_INFO" => _var(:home, :link))
end

get '/_index' do
	_tpl :_index
end



# ================================================
# administration
# ================================================
get '/a' do
 	redirect _url('/admin/info/system')
end

before '/admin/*' do
  	_login? _var(:login, :link)
	@menus = _menu(:admin)
end

get "/robots.txt" do
	arr = [
		"User-agent:*",
		"Disallow:/admin*",
		"Disallow:/_*",
	]
	arr.join("\n")
end



# ================================================
# scaffold using interface
# ================================================
# Fisrt
# a interface route that preformments the form submit, and record delete, or others
# you must to assign the rule to user allow to use this route
before '/_system/_opt' do
 	_level? _var(:form_submit_level)
# 	_rule? :system_opt
end

#
# Second
# the interface methods need to be added the '_' as the suffix
post '/_system/_opt' do
	method = params[:_method_] ? params[:_method_] : (@qs.include?(:_method_) ? @qs[:_method_] : nil)
	if method and method[-1] == '_' and self.respond_to?(method.to_sym)
		eval("#{method}")
	end
	@t[:repath] ||= (params[:_repath] || request.referer)
	redirect @t[:repath]
end
