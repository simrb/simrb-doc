module Simrb
	module Stool

		# method library of help tool

		# get the installed file by module name you need to install
		#
		# == Example
		#
		# 	system_get_install_file 'cms'		# return the result as below
		#
		# {
		# 	# this is a file in installed directory called _user
		# 	:_user	=>	[
		# 		{:name => 'guest', :pawd => 'guest'},
		# 		{:name => 'system', :pawd => 'system', :level => 99},
		# 		{:name => 'test', :pawd => 'test', :level => 2},
		# 	]
		# 	# as above, a file called _rule
		# 	:_rule	=>	[
		# 		{:name => 'admin'},
		# 		{:name => 'system_opt'},
		# 	]
		# }
		#
		def system_get_install_file module_name
			res			= {}
			files 		= Dir["#{Spath[:module]}#{module_name.to_s}#{Spath[:install]}*"]

			files_path	= Spath[:install_lock_file]
			files_lock	= []

			if Scfg[:install_lock] == 'yes'
				if File.exist? files_path
					files_lock = File.read(files_path).split("\n")
				else
					File.new(files_path, 'w')
				end

				files.each do | file |
					files.delete(file) if files_lock.include? file
				end

				unless files.empty?
					File.open(files_path, 'a') do | f |
						f.write(files.join("\n") + "\n")
					end
				end
			end

			files.each do | file |
				installer 		= file.split('/').last
				installer		= installer.split('.').first if installer.index('.')
				installer		= installer.to_sym
 				res[installer]  = []

				Simrb.yaml_read(file).each do | row |
					line = {}
					row.each do | k, v |
						line[k.to_sym] = v == nil ? '' : v
					end
					res[installer] << line
				end
			end

			res
		end

		# get the data block by module name
		#
		# == Example
		#
		# 	system_get_data_block 'cms'
		#
		def system_get_data_block name
			tables = []
			# if system module
			name = '' if name == 'system'

			Sdata.keys.each do | key |
				if key.to_s.start_with?("#{name}_")
					tables << key 
				end
			end
			tables.uniq
		end

		# generate many tpl with a given module name
		#
		# == Example
		#
		# generate more than one
		#
		# 	$3s system_generate_tpl demo before layout
		#
		# or, generate one
		#
		# 	$3s system_generate_tpl demo admin
		#
		def system_generate_tpl args
			modulename = args.shift(1)[0]
			args.uniq!
			args.each do | name |
				system_generate_file(eval("system_tpl_#{name} '#{modulename}'"))
			end
			'Implementing complete'
		end

		# generate file by path and content given
		# 
		# == Examples
		#	
		#	system_generate_file({'path' =>	'body'})
		#
		#	or
		#
		#	data = {
		# 		'path1'	=>	'the content in path1', 
		# 		'path2'	=>	'the content in path2', 
		# 	}
		#	system_generate_file(data)
		#
		def system_generate_file content
			content.each do | path, body |
				File.open(path, 'w') do | f |
					f.write body
				end
			end
		end

		# add the number suffix for path
		def system_add_suffix path
			path += ".#{(Dir[path + "*"].count + 1).to_s}"
		end

		# convert an hash block to string
		def system_hash_to_str table_name, data
			res = ""
			data.each do | k, v |
				res << "\t\t:#{k.to_s.ljust(23)}=>\t{\n"
				v.each do | k, v |
					res << "\t\t\t:#{k.to_s.ljust(19)}=>\t"
					if v.class.to_s == 'String'
						res << "'#{v}'"
					elsif v.class.to_s == 'Symbol'
						res << ":#{v}"
					else
						res << "#{v}"
					end
					res << ",\n"
				end
				res << "\t\t},\n"
			end
			res = "data :#{table_name} do\n\t{\n#{res}\t}\t\nend\n\n"
		end

		# return the content of erb file by path
		def system_get_erb path
			require 'erb'
			if File.exist? path
				content = File.read(path)
				t = ERB.new(content)
				t.result(binding)
			else
				"No such the file at #{path}" 
			end
		end

	end
end

