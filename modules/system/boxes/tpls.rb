module Simrb
	module Stool

		# /before.rb
		def system_tpl_helper module_name, file_name = ""
			tpl = ""
			tpl << "helpers '/#{module_name}/*' do\n\n"
			tpl << "\tdef #{module_name}_page name\n"

			tpl << "\t\t@layout ||= :#{module_name}_layout\n"
			tpl << "\t\t@t[:title] \t\t\t||= _var(:title, :#{module_name}_page)\n"
			tpl << "\t\t@t[:description] \t||= _var(:description, :#{module_name}_page)\n"
			tpl << "\t\t@t[:keywords] \t\t||= _var(:keywords, :#{module_name}_page)\n"
			tpl << "\t\t_tpl name, @layout\n"

			tpl << "\tend\n\n"
			tpl << "end"
			{"#{Spath[:module]}#{module_name}/helpers.rb" => tpl}
		end

		# /views/name_layout.slim
		def system_tpl_layout module_name, file_name = ""
			@et 		= { :name => module_name }
			tpl			= system_get_erb("#{Spath[:module]}system#{Spath[:tpl_layout]}")
			file_name 	= file_name == "" ? module_name : "#{module_name}_#{file_name}"
			path		= "#{Spath[:module]}#{module_name}#{Spath[:view]}#{file_name}_layout.slim"
			{path => tpl}
		end

		# /boxes/assets/name.css
		def system_tpl_css module_name, file_name = ""
			tpl 		= ""
			path 		= "#{Spath[:module]}system#{Spath[:tpl_css]}"
			file_name 	= file_name == "" ? module_name : "#{module_name}_#{file_name}"
			if File.exist? path
				tpl << File.read(path)
			end
			{"#{Spath[:module]}#{module_name}#{Spath[:assets]}#{file_name}.css" => tpl}
		end

		# /boxes/assets/name.js
		def system_tpl_js module_name, file_name = ""
			tpl 		= ""
			file_name 	= file_name == "" ? module_name : "#{module_name}_#{file_name}"
			{"#{Spath[:module]}#{module_name}#{Spath[:assets]}#{file_name}.js" => tpl}
		end

		# /.gitignore
		def system_tpl_gitignore module_name, file_name = ''
			tpl 		= ""
			path 		= "#{Spath[:module]}system#{Spath[:tpl].chomp("/")}#{Spath[:gitgnore]}"
			if File.exist? path
				tpl << File.read(path)
			end
			{"#{Spath[:module]}#{module_name}#{Spath[:gitgnore]}" => tpl}
		end

	end
end
