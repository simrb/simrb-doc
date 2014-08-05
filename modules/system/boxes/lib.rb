module Simrb
	module Stool

		# get the installed file by module name you need to install
		#
		# == Example
		#
		# 	system_get_install_file "demo"
		#
		# return the result as below
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
		# 	system_get_data_block "demo"
		#
		def system_get_data_block name = 'system'
			tables = []
			name = '' if name == 'system'

			Sdata.keys.each do | key |
				if key.to_s.start_with?("#{name}_") or key.to_s == name
					tables << key 
				end
			end
			tables.uniq
		end

		# add the number suffix for path
		def system_add_suffix path
			count 	= Dir[path, "#{path}.*"].count
			suffix 	= count > 0 ? ".#{count}" : ""
			path 	= "#{path}#{suffix}"
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
			res = "data :#{table_name} do\n\t{\n#{res}\t}\nend\n\n"
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

		# generate many tpl with a given module name
		#
		# == Example
		#
		# generate more than one
		#
		# 	$ 3s system_generate_tpl demo before layout
		#
		# or, generate one
		#
		# 	$ 3s system_generate_tpl demo admin
		#
		def system_generate_tpl args
			res			= {}
			module_name = args.shift(1)[0]

			args.uniq!
			args.each do | name |
				method = "system_tpl_#{name}"
				if self.respond_to? method.to_sym
					resh = eval("#{method} '#{module_name}'")
					res.merge! resh
					Simrb.path_init resh.keys[0], resh.values[0]
				end
			end

			res
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
# 		def system_generate_file content
# 			content.each do | path, body |
# 				File.open(path, 'w') do | f |
# 					f.write body
# 				end
# 			end
# 		end

		# generate the migration created by a data name that maybe is a table name
		#
		# == Examples
		#
		#	system_generate_migration_created table_name
		#
		def system_generate_migration_created name
			res		= ""
			data 	= _data_format(name)

			data.each do | key, val |
				type 	= val.include?(:primary_key) ? 'primary_key' : val[:type]
				options = {}
				options[:size] = val[:size] if val.include?(:size)

				res << "\t\t\t"
				res << "#{type} :#{key}"
				unless options.empty?
					res << options.collect { |k,v| ", :#{k} => #{v}" }.join
				end
				res << "\n"
			end

			res = "\t\tcreate_table(:#{name}) do\n#{res}\t\tend\n"
		end

		# generate the migration dropped, as the system_generate_migration_created
		def system_generate_migration_drop tables = []
			"\t\tdrop_table(:#{tables.join(', :')})\n"
		end

	end
end

