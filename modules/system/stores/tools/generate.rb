module Simrb
	module Stool
		
		# the shortcut of generated commands
		# assuming a module called demo, create the file template as below
		#
		#	$3s g data demo
		#	$3s g admin demo
		#	$3s g layout demo
		#
		#	$3s g vars demo
		#	$3s g menu demo
		#	$3s g m demo
		#
		def g args
			method = 'g_' + args.shift(1)[0]
			if Stool.method_defined? method
				eval("#{method} #{args}")
			end
		end

		# generate a _vars file to install dir
		#
		# 	$3s g vars demo
		#
		def g_vars args
			module_name = args.shift(1)[0]
			@et			= Array.new 4

			path		= system_add_suffix("modules/#{module_name}/#{Simrb::File[:vars]}")
			content		= system_get_erb("modules/#{Scfg[:main_module]}/#{Simrb::Dir[:docs]}/vars.erb")
			system_generate_file({path => content})
		end

		# generate a _menu file to install dir
		#
		# 	$3s g menu demo
		#
		def g_menu args
			module_name = args.shift(1)[0]
			@et			= Array.new 4

			path		= system_add_suffix("modules/#{module_name}/#{Simrb::File[:menu]}")
			content		= system_get_erb("modules/#{Scfg[:main_module]}/#{Simrb::Dir[:docs]}/menu.erb")
			system_generate_file({path => content})
		end

		# generate a admin borad of background, it requires the data block
		#
		# == Example
		#
		# 	$3s g_admin demo
		#
		def g_admin args
			args += ['admin', 'menu']
			g_tpl args
		end

		# generate the layout template
		def g_layout args
			args += ['helper', 'layout', 'layout_css', 'js', 'var']
			g_tpl args
		end

		# generate many tpl with a given module name
		#
		# == Example
		#
		# generate more than one
		#
		# 	$3s g_tpl demo before layout
		#
		# or, generate one
		#
		# 	$3s g_tpl demo admin
		#
		def g_tpl args
			modulename = args.shift(1)[0]
			args.uniq!
			args.each do | name |
				system_generate_file(eval("system_tpl_#{name} '#{modulename}'"))
			end
			'Implementing complete'
		end

		# generate a migration file by a data block
		#
		# == Example
		# generates a migration file at stores/migrations/filename,
		# if it has the data block that will be saved at dir logics/data.rb
		#
		# 	$3s g_m2 modulename filename_or_tablename
		#
		def g_m2 args
			if args.count == 2
				modulename, filename = args
				dir 	= "modules/#{modulename}/#{Simrb::Dir[:schema]}"
				count 	= Dir[dir + "/*"].count + 1
				fname 	= "#{filename}_#{Time.now.strftime('%y%m%d')}" 
				path 	= dir + "/#{count.to_s.rjust(3, '0')}_#{fname}.rb"

				# create file
				#File.new(path, 'w') if File.exist? path

				# input content to file
				args = [filename]
				system_generate_file({path => g_m_c(args)})
				"Implementing complete"
			else
				"You need 2 arguments"
			end
		end

		# generate one or more migration files by a module name
		#
		# == Examples
		#
		# 	$3s g_m demo
		#
		def g_m args
			if args.empty?
				iputs "no module name given" 
				exit
			else
				modulename = args[0]
			end

			content			= ''
			operations		= []
			db_tables 		= DB.tables
			create_tables 	= []
			drop_tables		= []
			alter_tables	= []
			data_tables 	= system_fetch_data modulename

			# create tables
			data_tables.each do | table |
				create_tables << table unless db_tables.include?(table)
			end

			# drop tables
			db_tables.each do | table |
				unless data_tables.include?(table)
					drop_tables << table if table.to_s.start_with?("#{modulename}_")

				# check it for altering tables
				else
					data_cols 	= _data(table).keys
					db_cols		= DB[table].columns
				end
			end

			# generate content
			unless create_tables.empty?
				operations << :create
				create_tables.each do | table |
					content << g_m_c(table)
				end
			end

			unless drop_tables.empty?
				operations << :drop
				drop_tables.each do | table |
					content << g_m_d(table)
				end
			end
	
			# write the migration file
			if content != ''
				dir 	= "modules/#{modulename}/#{Simrb::Dir[:schema]}"
				count 	= Dir[dir + "/*"].count + 1
				fname 	= args[1] ? args[1] : "#{operations.join('_')}_#{Time.now.strftime('%y%m%d')}" 
				path 	= dir + "/#{count.to_s.rjust(3, '0')}_#{fname}.rb"
				content = "Sequel.migration do\n\tchange do\n#{content}\tend\nend\n"

				system_generate_file({path => content})
			end

			"generate the content to #{path}\n\n#{content}"
		end

		# generate the migration file content of create event by data name as the table name
		#
		# == Examples
		#
		#	g_m_c tablename
		#
		def g_m_c name
			content = ""
			data 	= _data_format(name)

			data.each do | key, val |
				type 	= val.include?(:primary_key) ? 'primary_key' : val[:type]
				options = {}
				options[:size] = val[:size] if val.include?(:size)

				content << "\t\t\t"
				content << "#{type} :#{key}"
				unless options.empty?
					content << options.collect { |k,v| ", :#{k} => #{v}" }.join
				end
				content << "\n"
			end

			content = "\t\tcreate_table(:#{name}) do\n#{content}\t\tend\n"
		end

		# drop table, as the g_m_c
		def g_m_d tables = []
			"\t\tdrop_table(:#{tables.join(', :')})\n"
		end

		# change an array to a hash of data block
		# 
		# == Arguments
		# args is an array
		# auto, default is true that auto add the primary key if no given, closed is false 
		#
		# == Examples
		# 01, no primary key, it will auto adds one, and auto assign the default value
		#
		# 	g_data ['table_name', 'field1', 'field2']
		#
		# output
		#
		# 	{
		# 		:table_name	=>	{
		# 			:field0	=>	{ :pramiry_key => true },
		# 			:field1	=>	{ :default => ''},
		# 			:field2	=>	{ :default => ''},
		# 		}
		# 	}
		#
		# 02, specifying the field type, default is string if no given value
		#
		# 	g_data ['table_name', 'field1:pk', 'field2:int', 'field3:text', 'field4']
		#
		# output
		#
		# 	{
		# 		:table_name	=>	{
		# 			:field1	=>	{ :pramiry_key => true },
		# 			:field2	=>	{ :type	=> :integer },
		# 			:field3	=>	{ :type	=> :text },
		# 			:field4	=>	{ :default => ''},
		# 		}
		# 	}
		#
		# 03, more parameters of field
		#
		# 	g_data ['table_name', 'field1:pk', 'field2:int=1:label=newfieldname', 'field3:int=1:assoc_one=table,name']
		#
		# output
		#
		# 	{
		# 		:table_name	=>	{
		# 			:field1	=>	{ :pramiry_key => true },
		# 			:field2	=>	{ :type	=> :integer, :default => 1, :label => :newfieldname },
		# 			:field3	=>	{ :default => 1, :assoc_one => [:table, :name] },
		# 		}
		# 	}
		def g_data args, auto = true
			nopk 		= true
			table 		= args.shift
			module_name = table.index('_') ? table.split('_').first : table
			data 		= {}

			# the item options should be this
			#
			# 	'field'
			# 	'field:pk'
			# 	'field:str'
			# 	'field:int'
			# 	'field:int=1'
			# 	'field:text'
			# 	'field:int=1:label=newfield:assoc_one=tablename,fieldname'
			#
			# the fisrt one is field name,
			# the second one is field type(or primary key, )
			# the others maybe anything

			key_alias 	= [:pk, :fk, :index, :unique]

			args.each do | item |
				if item.include?(":")
					arr = item.split(":")

					# fisrt item is field name
					field = (arr.shift).to_sym
					data[field] = {}

					# second item is field type
					if arr.length > 0
 						unless arr[0].include?('=')
							type = (arr.shift).to_sym

							# normal field type
							if Simrb::Alias.keys.include? type
								data[field][:type] = Simrb::Alias[type]

							# main keys
							elsif key_alias.include? type
								if type == :pk
									data[field][:primary_key] = true 
									nopk = false
								else
								end
							else
								data[field][:type] = type.to_s
							end

						end
					end

					# the other options of field
					if arr.length > 0
						arr.each do | a |
							if a.include? "="
								key, val = a.split "="
								if val.include? ','
									val = val.split(',').map { |v| v.to_sym }
								end
								data[field][key.to_sym] = val
							end
						end
					end
				else
					data[item.to_sym] = {}
					data[item.to_sym][:default] = ''
				end
			end

			# processes the complex key - type alias
			data.each do | field, vals |
				Simrb::Alias.keys.each do | key |
					if data[field].include? key
						data[field][:type] 		= Simrb::Alias[key]
						data[field][:default] 	= key == :int ? data[field][key].to_i : data[field][key]
						data[field].delete key
					end
				end
			end

			# autocompletes the primary key
			if auto == true and nopk
				h = {"#{table}_id".to_sym => {:primary_key => true}}
				data = h.merge(data)
			end

			# write res to data.rb
			res 	= system_convert_str table, data
			path 	= "modules/#{module_name}/#{Simrb::Dir[:logic]}/data.rb"
# 			unless File.exist? path
# 				File.new(path, 'w')
# 			end
# 			File.open(path, 'a') do | f |
# 				f.write res
# 			end
			res << 'generate content as above'
		end

	end
end
