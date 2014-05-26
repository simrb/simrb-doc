require 'sinatra'
require 'sinatra/base'
require 'sequel'
require 'slim'

#######################
# common methods
#######################
def read_kv_file path
	res		= {}
	content = File.read path
	content = content.index("\n") ? content.split("\n") : [content]
	content.each do | line |
		if line.index("=") and line[0] != '#'
			key, val = line.split("=")
			# value is an array
			if val.index(',')
				res[key.strip.to_sym] = val.split(',').map { |v| v.strip }

			# value is a string
			else
				res[key.strip.to_sym] = val.strip
			end
		end
	end
	res
end

def iputs args
	args = args.class.to_s == 'Array' ? args.join("\n") : args.to_s
	puts "="*30
	puts args
	puts "="*30
end


#######################
# base configs
#######################
Sdir = Dir.pwd + '/'
module Simrb
	module Sbase

		# default generated directories
		Dir					= {
			:store			=> 'stores',
			:logic			=> 'logics',
			:view			=> 'views',
			:assets			=> 'views/assets',
			:lang			=> 'stores/langs',
			:docs			=> 'stores/docs',
			:schema			=> 'stores/migrations',
			:tool			=> 'stores/tools',
			:install		=> 'stores/installs',
		}

		# default generated files
		File				= {
			:route			=> 'logics/routes.rb',
			:gemfile		=> 'stores/Gemfile',
			:modinfo		=> 'stores/installs/_mods',
			:readme			=> 'README.md',
			:vars			=> 'stores/installs/_vars',
			:menu			=> 'stores/installs/_menu',
		}

		# default installed dirs
		Defdir				= [:logic, :store, :view, :assets, :lang, :install, :docs, :schema, :tool]

		# default installed files
		Defile				= [:route, :gemfile, :modinfo, :readme]

		# document or template file
		Docs				= {
 			:layout_css		=> 'stores/docs/layout.css',
 			:common_css		=> 'stores/docs/common.css',
		}

		# default scfg file settings
		Scfg				= {
			:requiredb		=> 'yes',
			:main_module	=> 'system',
			:disable_modules=> [],
			:encoding		=> 'utf-8',
			:lang			=> 'en',
			:install_lock	=> 'yes',
			:db_connect		=> 'sqlite://db/data.db',
			:upload_dir		=> Sdir + 'db/upload/',
			:backup_dir		=> Sdir + 'db/backup/',
			:tmp_dir		=> Sdir + 'tmp',
			:log_dir		=> Sdir + 'log',
			:log			=> Sdir + 'log/thin.log',
			:cache_dir		=> '/var/cache/simrb/',
			:time_types		=> ['created', 'changed'],
			:fixnum_types	=> ['order', 'level'],
			:number_types 	=> ['Fixnum', 'Integer', 'Float'],
			:environment 	=> 'development',	# or production, test
			:server 		=> 'thin',
			:bind 			=> '0.0.0.0',
			:port			=> 3000,
		}

		# field type alias
		Alias				=	{
			:int 			=> 'Fixnum',
			:str 			=> 'String',
			:text 			=> 'Text',
			:time			=> 'Time',
			:big			=> 'Bignum',
			:fl				=> 'Float',
		}

	end
end
include Simrb

# a config file of key-val
File.open('scfg', 'w') unless File.exist? 'scfg'
Scfg = Sbase::Scfg
Scfg.merge!(read_kv_file('scfg'))

# initialize default dirs
Dir.mkdir 'db' unless File.exist? 'db'
Dir.mkdir Scfg[:tmp_dir] unless File.exist? Scfg[:tmp_dir]
Dir.mkdir Scfg[:log_dir] unless File.exist? Scfg[:log_dir]
Dir.mkdir Scfg[:upload_dir] unless File.exist? Scfg[:upload_dir]
Dir.mkdir Scfg[:backup_dir] unless File.exist? Scfg[:backup_dir]

unless File.exist? 'scfg'
	File.open('scfg', 'w+') do | f |
		f.write "environment=#{Scfg[:environment]}"
	end
end


#######################
# database configs
#######################
set :environment, Scfg[:environment].to_sym

configure do
	
	# open local static files
# 	set :static, true
# 	set :root, Sdir

	DB = Sequel.connect(Scfg[:db_connect])

end

configure :production do

	not_found do
		L['Sorry, no page']
	end

	error do
		'Sorry there was a nasty error - ' + env['sinatra.error'].name
	end

end


