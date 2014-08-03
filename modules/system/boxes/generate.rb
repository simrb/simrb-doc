# 
# the file supports a few of method interface that generates something content to specified file
# like, installing file, migration file
#

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
			method = args.shift(1)[0]

			# transform method by short name
			shortcut = {'m' => 'migration', 'inst' => 'install'}
			method = shortcut[method] if shortcut.keys.include? method
			method = 'g_' + method

			# implement
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
			args, opts	= Simrb.input_format args
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
			# 	'field:int=1:label=newfield:assoc_one=table_name,fieldname'
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

			# write content to data.rb
			res 	= system_hash_to_str table, data
			path 	= "#{Spath[:module]}#{module_name}/data.rb"
			if write_file == true
				Simrb.path_init path
				File.open(path, 'a') do | f |
					f.write res
				end
 			end

			# display result
			"The following content is generated at #{path} \n\n" << res
		end

		# generate the migration file by a gvied module name
		#
		# == Examples
		#
		# 	$ 3s g_m demo
		#
		def g_migration args
			if args.empty?
				Simrb.p "no module name given" 
				exit
			else
				module_name = args[0]
			end

			res				= ''
			operations		= []
			db_tables 		= Sdb.tables
			create_tables 	= []
			drop_tables		= []
			alter_tables	= []
			data_tables 	= system_get_data_block module_name

			# create tables
			data_tables.each do | table |
				create_tables << table unless db_tables.include?(table)
			end

			# drop tables
			db_tables.each do | table |
				unless data_tables.include?(table)
					drop_tables << table if table.to_s.start_with?("#{module_name}_")

				# check it for altering tables
				else
					data_cols 	= _data(table).keys
					db_cols		= Sdb[table].columns
				end
			end

			# generate result of creating event
			unless create_tables.empty?
				operations << :create
				create_tables.each do | table |
					res << system_generate_migration_created(table)
				end
			end

			# generate result of drop event
			unless drop_tables.empty?
				operations << :drop
				drop_tables.each do | table |
					res << system_generate_migration_drop(table)
				end
			end

			# write result to the migration file
			if res != ''
				dir 	= "#{Spath[:module]}#{module_name}#{Spath[:schema]}"
				count 	= Dir[dir + "*"].count + 1
				fname 	= args[1] ? args[1] : "#{operations.join('_')}_#{Time.now.strftime('%y%m%d')}" 
				path 	= "#{dir}#{count.to_s.rjust(3, '0')}_#{fname}.rb"
				res		= "Sequel.migration do\n\tchange do\n#{res}\tend\nend\n"

				system_generate_file({path => res})
			end

			# display result
			"The following content is generated at #{path} \n\n" << res
		end

		# generate a file in installed dir
		#
		# == Example
		#
		# 	$ 3s g install --demo _menu
		# 	$ 3s g install --demo _menu name:myMenu link:myLink 
		# 	$ 3s g inst _vars vkey:myvar vval:myval --demo
		#
		# the first option with -- that is the module dir where you want the content generated to
		# `inst` is a alias name of `install`
		#
		def g_install args
			args, opts	= Simrb.input_format args
			module_name = opts.keys[0]
			table_name	= args.shift(1)[0]
			res 		= ""
			path 		= "#{Spath[:module]}#{module_name}#{Spath[:install]}#{table_name}"

			# default value of giving by command arguments
			resh 		= {}
			args.each do | item |
				key, val = item.split ":"
				resh[key.to_sym] = val
			end

			_data_format(table_name).each do | k, v |
				if v.include? :primary_key
				elsif [:created, :changed, :uid, :parent].include? k
				else
					v[:default] = resh[k] if resh.include? k
					res << "  #{k.to_s.ljust(15)}: #{v[:default]}\n"
				end
			end

			res[0] = '-'
			res << "\n"

			# write file
			unless File.exist? path
				Simrb.path_init path
				res = "---\n" + res
			end

			File.open(path, "a") do | f |
				f.write res
			end

			# display the result
			"The following content is generated at #{path} \n\n" << res
		end

		# generate an administration list of background
		#
		# == Example
		#
		# 	$ 3s g_admin demo
		#
		def g_admin args
			args += ['admin', 'menu']
			system_generate_tpl args
		end

		# generate view file
		#
		def g_view
		end

		# generate the layout template
		def g_layout args
			args += ['helper', 'layout', 'layout_css', 'js', 'var']
			system_generate_tpl args
		end

	end
end
