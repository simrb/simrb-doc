# 
# the file stores the basic commands
# like, implement the db migration record, install module, new and clone module 
#

module Simrb
	module Stool

		# run the migration file
		#
		# == Examples
		#
		# run all of module migrations
		#
		# 	$ 3s db
		#
		# run the migrations for the specified module 
		#
		# 	$ 3s db user cms
		#
		def db args = []
			args = Smodules if args.empty?
			args.each do | mod_name |
				path = "modules/#{mod_name}#{Spath[:schema]}".chomp("/")
				if Dir[path + '/*'].count > 0
					Sequel.extension :migration
					Sequel::Migrator.run(Sdb, path, :column => mod_name.to_sym, :table => :_schemas)
				end
			end

			"Successfully implemented the migration records"
		end

		# install a module
		#
		# == Examples
		# 
		# install all of module, it will auto detects
		#
		# 	$ 3s install
		#
		# or, install the specified module
		# 	
		# 	$ 3s install blog
		#
		def install args = []
			args = Smodules if args.empty?

			# step 1, run migration files
			db args

			# step 2, run the gemfile
			args.each do | module_name |
				path = "modules/#{module_name}#{Spath[:gemfile]}"
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
				installer_ds = system_get_install_file module_name

				# run installer
				installer_ds.each do | name, data |
					installer = "#{name}_installer"
					if self.respond_to?(installer.to_sym)
						eval("#{installer} #{data}")

					# if no installer, submit the data with default method
					else
						data.each do | row |
  							_submit name.to_sym, :fkv => row, :unqi => true, :valid => false
						end
					end
				end

				# installed hoot after
				installer = "#{module_name}_install_after"
				eval("#{installer}") if self.respond_to?(installer.to_sym)
			end

			"Successfully installed"
		end

		# get a module from github to local modules dir
		#
		# == Example
		# 
		# 	$ 3s get simrb/test
		#
		def get args = []
			require 'simrb/comd'
			simrb_app = Simrb::Scommand.new
			simrb_app.run(args.unshift('get'))

			"Successfully got a module from remote repository"
		end

		# create a module, initializes the default dirs and files of module
		#
		# == Example
		# 
		# 	$ 3s new demo
		#
		def new args
			require 'simrb/comd'
			simrb_app = Simrb::Scommand.new
			simrb_app.run(args.unshift('new'))

			"Successfully initialized an empty module directory"
		end

	end
end

