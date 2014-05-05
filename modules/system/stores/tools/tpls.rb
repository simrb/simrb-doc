module Simrb
	module Stool

		# /logics/before.rb
		def system_tpl_helper modulename
			tpl = ""
			tpl << "helpers '/#{modulename}/*' do\n\n"
			tpl << "\tdef #{modulename}_page name\n"

			tpl << "\t\t@layout ||= :#{modulename}_layout\n"
			tpl << "\t\t@t[:title] \t\t\t||= _var(:title, :#{modulename}_page)\n"
			tpl << "\t\t@t[:description] \t||= _var(:description, :#{modulename}_page)\n"
			tpl << "\t\t@t[:keywords] \t\t||= _var(:keywords, :#{modulename}_page)\n"
			tpl << "\t\t_tpl name, @layout\n"

			tpl << "\tend\n\n"
			tpl << "end"
			{"modules/#{modulename}/#{Sbase::Dir[:logic]}/helpers.rb" => tpl}
		end

		# /logics/admin.rb
		def system_tpl_admin modulename
			datas 		= system_fetch_data modulename.to_sym
			tpl 		= ""
			tpl << "get '/admin/#{modulename}' do\n"
			tpl << "\tadmin_page :admin_info\n"
			tpl << "end\n\n"

			datas.each do | name |
				tpl << "get '/admin/#{name}' do\n"
				tpl << "\t_admin :#{name}\n"
				tpl << "end\n\n"
			end
			{"modules/#{modulename}/#{Sbase::Dir[:logic]}/admin.rb" => tpl}
		end

		# /stores/installs/_menu 
		def system_tpl_menu modulename
			datas = system_fetch_data modulename.to_sym
			tpl = ""
			tpl << "name\t= #{modulename}\n"
			tpl << "link\t= /admin/#{modulename}\n"
			tpl << "tag\t= admin\n\n"

			datas.each do | name |
				tpl << "name\t= #{name}\n"
				tpl << "link\t= /admin/#{name}\n"
				tpl << "parent\t= #{modulename}\n"
				tpl << "tag\t\t= admin\n\n"
			end
			{"modules/#{modulename}/#{Sbase::Dir[:install]}/_menu" => tpl}
		end

		# /views/name_layout.slim
		def system_tpl_layout modulename
			@et = { :name => modulename }
			tpl	= system_get_erb("modules/#{Scfg[:main_module]}/#{Sbase::Dir[:docs]}/layout.erb")
			{"modules/#{modulename}/#{Sbase::Dir[:view]}/#{modulename}_layout.slim" => tpl}
		end

		# /stores/assets/name.css
		def system_tpl_layout_css modulename
			tpl = ""
			path = "modules/system/#{Sbase::Docs[:layout_css]}"
			if File.exist? path
				tpl << File.read(path)
			end
			{"modules/#{modulename}/#{Sbase::Dir[:assets]}/#{modulename}.css" => tpl}
		end

		def system_tpl_common_css modulename
			tpl = ""
			path = "modules/system/#{Sbase::Docs[:common_css]}"
			if File.exist? path
				tpl << File.read(path)
			end
			{"modules/#{modulename}/#{Sbase::Dir[:assets]}/#{modulename}_common.css" => tpl}
		end

		# /stores/assets/name.js
		def system_tpl_js modulename
			tpl = ""
			{"modules/#{modulename}/#{Sbase::Dir[:assets]}/#{modulename}.js" => tpl}
		end

		# /stores/installs/_vars
		def system_tpl_var modulename
			tpl = ""
			[:title, :description, :keywords, :footer].each do | name |
				tpl << "vkey\t= #{name}\n"
				tpl << "vval\t= #{modulename}\n"
				tpl << "tag\t\t= #{modulename}_page\n"
				tpl << "descpt\t= \n\n"
			end
			{"modules/#{modulename}/#{Sbase::Dir[:install]}/_vars" => tpl}
		end

	end
end
