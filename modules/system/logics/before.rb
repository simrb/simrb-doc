# ================================================
# global
# ================================================
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
 	redirect '/admin/info'
end

before '/admin/*' do
  	_login? _var(:login, :link)
	@menus = _menu(:admin)
end

get "/robots.txt" do
	arr = []
	arr << "User-agent:*"
	arr << "Disallow:/admin*"
	arr << "Disallow:/_*"
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
