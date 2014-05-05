module Simrb
	module Stool

		# base command to use

		# run the migration file
		#
		# == Examples
		#
		# run all of module migrations
		#
		# 	$3s db
		#
		# run the migrations for the specified module 
		#
		# 	$3s db user cms
		#
		def db args = []
			args = system_fetch_modules if args.empty?
			args.each do | mod_name |
				path = "modules/#{mod_name}/#{Sbase::Dir[:schema]}"
				if Dir[path + '/*'].count > 0
					Sequel.extension :migration
					Sequel::Migrator.run(DB, path, :column => mod_name.to_sym, :table => :_schemas)
				end
			end
			"Implementing migration complete!"
		end

		# initialize base operation by bundling gems and injecting the bash command
		#
		# == Example
		# 
		# 	$3s init
		#
		def init
			# bundle gems
			`bundle install --gemfile=modules/"#{Scfg[:main_module]}"/#{Sbase::File[:gemfile]}`

			# add the bash commands to your ~/.bashrc file
			`echo 'alias 3s="ruby cmd.rb"' >> ~/.bashrc && source`
			"Initializing complete"
		end

		# clone a module from github to modules dir
		#
		# == Example
		# 
		# 	$3s clone coolesting/cms
		#
		def clone args = []
			`git clone git://github.com/#{args[0]}.git modules/#{args[0].split('/').last}`
		end

		# create a module, initializes the default dirs and files of module
		#
		# == Example
		# 
		# 	$3s new blog
		#
		def new args
			args.each do | module_name |
				# module dir
				`mkdir modules/#{module_name}`

				# sub dirs of module
				Sbase::Defdir.each do | name |
					`mkdir modules/#{module_name}/#{Sbase::Dir[name]}`
				end

				# default files of module dir
				Sbase::Defile.each do | name |
 					`touch modules/#{module_name}/#{Sbase::File[name]}`
				end

				# echo module info
				`echo name=#{module_name} >> modules/#{module_name}/#{Sbase::File[:modinfo]}`
			end

			"Initializing module directory complete"
		end

		# install a module
		#
		# == Examples
		# 
		# install all of module, it will auto detects
		#
		# 	$3s install
		#
		# or, install the specified module
		# 	
		# 	$3s install blog
		#
		def install args = []
			args = system_fetch_modules if args.empty?

			# step 1, run migration files
			db args

			# step 2, run the gemfile
			args.each do | module_name |
				path = "modules/#{module_name}/#{Sbase::File[:gemfile]}"
				if File.exist? path
					`bundle install --gemfile=#{path}`
				end
			end

			# step 3, submit the data to database
			args.each do | module_name |

				# installed hoot before
				installer = "#{module_name}_install_before"
				eval("#{installer}") if self.respond_to?(installer.to_sym)

				# fetch datas that need to be insert to db
				installer_ds = system_fetch_install module_name

				# run installer
				installer_ds.each do | name, data |
					installer = "#{name}_installer"
					if self.respond_to?(installer.to_sym)
						eval("#{installer} #{data}")

					# if no installer, submit the data with default method
					else
						data.each do | row |
  							_submit :name => name.to_sym, :fkv => row, :unqi => true, :valid => false
						end
					end
				end

				# installed hoot after
				installer = "#{module_name}_install_after"
				eval("#{installer}") if self.respond_to?(installer.to_sym)
			end

			"Installing complete"
		end

	end
end

