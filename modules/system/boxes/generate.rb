module Simrb
	module Stool

		# a shortcut for all of generating commands
		#
		# == Example
		#
		# assume a module called demo, so
		#
		#	$ 3s g data demo
		#	$ 3s g m demo
		#	$ 3s g view demo form
		#
		# the result as same as the below, just lack of the underline between methods
		#
		# 	$ 3s g_data demo
		# 	$ 3s g_m demo
		#	$ 3s g_view demo form
		#
		def g args = []
			method = 'g_' + args.shift(1)[0]
			if Stool.method_defined? method
				eval("#{method} #{args}")
			end
		end

		# generate the data block from a input array to a output hash
		#
		# == Examples
		#
		# Example 01, normal mode
		#
		# 	$ 3s g_data table_name field1 field2
		#
		# output
		#
		# 	{
		# 		:table_name	=>	{
		# 			:field1	=>	{ :default 		=> ''},
		# 			:field2	=>	{ :default 		=> ''},
		# 		}
		# 	}
		#
		#
		# Example 02, specify the field type, by default, that is string
		#
		# 	$ 3s g_data table_name field1:pk field2:int field3:text field4
		#
		# output
		#
		# 	{
		# 		:table_name	=>	{
		# 			:field1	=>	{ :pramiry_key	=> true },
		# 			:field2	=>	{ :type			=> 'Fixnum' },
		# 			:field3	=>	{ :type			=> 'Text' },
		# 			:field4	=>	{ :default		=> ''},
		# 		}
		# 	}
		#
		#
		# Example 03, more parameters of field
		#
		# 	$ 3s g_data table_name field1:pk field2:int=1:label=newfieldname field3:int=1:assoc_one=table,name
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
		#
		def g_data args = []
			args, opts	= Simrb.format_input args
			auto		= opts[:auto] ? true : false
			write_file	= opts[:nowf] ? false : true
 			has_pk 		= false
			table 		= args.shift
			module_name = opts[:module] || (table.index('_') ? table.split('_').first : table)
			key_alias 	= [:pk, :fk, :index, :unique]
			data 		= {}

			# the additional options of field should be this
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
			# the second one is field type, or primary key, or other key
			# the others is extend

			# format the data block from an array to an hash
			args.each do | item |
				if item.include?(":")
					arr = item.split(":")

					# set field name
					field = (arr.shift).to_sym
					data[field] = {}

					# set field type
					if arr.length > 0
						# the second item that allows to be not the field type, 
						# it could be ignored by other options with separator sign "="
 						unless arr[0].include?('=')
							type = (arr.shift).to_sym

							# normal field type
							if Scfg[:field_alias].keys.include? type
								data[field][:type] = Scfg[:field_alias][type]

							# main keys
							elsif key_alias.include? type
								if type == :pk
									data[field][:primary_key] = true 
									has_pk = true
								else
								end
							else
								data[field][:type] = type.to_s
							end

						end
					end

					# the other items of field
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
# 					data[item.to_sym][:default] = ''
				end
			end

			# complete the field type and default value, 
			# because those operatings could be ignored at last step.
			data.each do | field, vals |
				# replace the field type with its alias
				Scfg[:field_alias].keys.each do | key |
					if data[field].include? key
						data[field][:type] 		= Scfg[:field_alias][key]
						data[field][:default] 	= key == :int ? data[field][key].to_i : data[field][key]
						data[field].delete key
					end
				end

				# the association field that default type is Fixnum (integer)
				if data[field].include? :assoc_one
					data[field][:type] = Scfg[:number_types][0]
				end
			end

			# automatically match the primary key
			if auto == true and has_pk == false
				h = {"#{table}_id".to_sym => {:primary_key => true}}
				data = h.merge(data)
			end

			# write res to data.rb
			res 	= system_convert_str table, data
			path 	= "#{Spath[:module]}#{module_name}/data.rb"
			if write_file == true
				Simrb.path_init path
				File.open(path, 'a') do | f |
					f.write res
				end
 			end
			res << Sl['generate content as above']
		end

		# generate one or more migration files by a module name
		#
		# == Examples
		#
		# 	$ 3s g_m demo
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
			db_tables 		= Sdb.tables
			create_tables 	= []
			drop_tables		= []
			alter_tables	= []
			data_tables 	= system_get_data_block modulename

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
					db_cols		= Sdb[table].columns
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
				dir 	= "modules/#{modulename}#{Spath[:schema]}"
				count 	= Dir[dir + "*"].count + 1
				fname 	= args[1] ? args[1] : "#{operations.join('_')}_#{Time.now.strftime('%y%m%d')}" 
				path 	= "#{dir}#{count.to_s.rjust(3, '0')}_#{fname}.rb"
				content = "Sequel.migration do\n\tchange do\n#{content}\tend\nend\n"

				system_generate_file({path => content})
			end

			"generate the content to #{path}\n\n#{content}"
		end

		# generate a migration file by a data block
		#
		# == Example
		#
		# generates a migration file at boxes/migrations/filename,
		# if it has the data block , that will be saved as data.rb in root dir of module
		#
		# 	$ 3s g_m2 modulename filename_or_tablename
		#
		def g_m2 args
			if args.count == 2
				modulename, filename = args
				dir 	= "modules/#{modulename}#{Spath[:schema]}"
				count 	= Dir[dir + "*"].count + 1
				fname 	= "#{filename}_#{Time.now.strftime('%y%m%d')}" 
				path 	= "#{dir}#{count.to_s.rjust(3, '0')}_#{fname}.rb"

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

		# generate a file in installed dir
		#
		# == Example
		#
		# 	$ 3s g install _vars
		# 	$ 3s g install _menu
		#
		# or, the same as below
		#
		# 	$ 3s g install _vars _menu
		#
		def g_install args
			# _vars
			module_name = args.shift(1)[0]
			@et			= Array.new 4

			path		= system_add_suffix("modules/#{module_name}#{Spath[:vars]}")
			content		= system_get_erb("modules/#{Scfg[:main_module]}#{Spath[:tpl]}vars.erb")
			system_generate_file({path => content})

			# _menu
			module_name = args.shift(1)[0]
			@et			= Array.new 4

			path		= system_add_suffix("modules/#{module_name}#{Spath[:menu]}")
			content		= system_get_erb("modules/#{Scfg[:main_module]}#{Spath[:tpl]}menu.erb")
			system_generate_file({path => content})
		end

		# generate view file
		#
		def g_view
		end

		# generate an admin borad of background, it requires the data block
		#
		# == Example
		#
		# 	$ 3s g_admin demo
		#
		def g_admin args
			args += ['admin', 'menu']
			system_generate_tpl args
		end

		# generate the layout template
		def g_layout args
			args += ['helper', 'layout', 'layout_css', 'js', 'var']
			system_generate_tpl args
		end

	end
end
