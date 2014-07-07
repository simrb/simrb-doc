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
			{"modules/#{modulename}#{Spath[:logic]}helpers.rb" => tpl}
		end

		# /logics/admin.rb
		def system_tpl_admin modulename
			datas 		= system_get_data_block modulename.to_sym
			tpl 		= ""
			tpl << "get '/admin/#{modulename}' do\n"
			tpl << "\tadmin_page :admin_info\n"
			tpl << "end\n\n"

			datas.each do | name |
				tpl << "get '/admin/#{name}' do\n"
				tpl << "\t_admin :#{name}\n"
				tpl << "end\n\n"
			end
			{"modules/#{modulename}#{Spath[:logic]}admin.rb" => tpl}
		end

		# /views/name_layout.slim
		def system_tpl_layout modulename
			@et = { :name => modulename }
			tpl	= system_get_erb("modules/#{Scfg[:main_module]}#{Spath[:docs]}layout.erb")
			{"modules/#{modulename}#{Spath[:view]}#{modulename}_layout.slim" => tpl}
		end

		# /stores/assets/name.css
		def system_tpl_layout_css modulename
			tpl = ""
			path = "modules/system#{Spath[:layout_css]}"
			if File.exist? path
				tpl << File.read(path)
			end
			{"modules/#{modulename}#{Spath[:assets]}#{modulename}.css" => tpl}
		end

		def system_tpl_common_css modulename
			tpl = ""
			path = "modules/system#{Spath[:common_css]}"
			if File.exist? path
				tpl << File.read(path)
			end
			{"modules/#{modulename}#{Spath[:assets]}#{modulename}_common.css" => tpl}
		end

		# /stores/assets/name.js
		def system_tpl_js modulename
			tpl = ""
			{"modules/#{modulename}#{Spath[:assets]}#{modulename}.js" => tpl}
		end

		# /stores/installs/_menu 
		def system_tpl_menu modulename
			datas 	= system_get_data_block modulename.to_sym
			tpl		= []
			tpl		<< { 'name' => modulename, 'link' => "/admin/#{modulename}", 'tag' => 'admin'}

			datas.each do | name |
				tpl	<< {
					'name' => name, 
					'link' => "/admin/#{modulename}",
					'parent' => modulename,
					'tag' => 'admin'
				}
			end

			require 'yaml'
			{"modules/#{modulename}#{Spath[:install]}_menu" => tpl.to_yaml}
		end

		# /stores/installs/_vars
		def system_tpl_var modulename
			tpl	= []

			[:title, :description, :keywords, :footer].each do | name |
				tpl << {
					"vkey"	=> name,
					"vval"	=> modulename,
					"tag"	=> "#{modulename}_page",
					"descpt"=> "no description"
				}
			end

			require 'yaml'
			{"modules/#{modulename}#{Spath[:install]}_vars" => tpl.to_yaml}
		end

	end
end
