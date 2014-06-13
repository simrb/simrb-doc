require 'sinatra'
require 'sinatra/base'
require 'sequel'
require 'slim'

Sdir = Dir.pwd + '/'
module Simrb

	# common methods
	class << self

		def read_file path
			require 'yaml'
			YAML.load_file path
		end

		def write_file path, data
			require "yaml"
			File.open(path, 'w+') do | f |
				f.write data.to_yaml
			end
		end

		def p args
			args = args.class.to_s == 'Array' ? args.join("\n") : args.to_s
			puts "="*30 + "\n" + args + "\n" + "="*30
		end

	end

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
		:db_dir			=> Sdir + 'db',
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

# load the customized file
Scfg = Simrb::Scfg
Simrb.read_file('scfg').each do | k, v |
	Scfg[k.to_sym] = v
end

unless File.exist? 'scfg'
	data = {}
	[:environment, :bind, :port].each do | opt |
		data[opt] = Scfg[opt]
	end
	Simrb.write_file('scfg', data)
end

# initialize default dirs
[:db_dir, :tmp_dir, :log_dir, :upload_dir, :backup_dir].each do | dir |
	Dir.mkdir Scfg[dir] unless File.exist? Scfg[dir]
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

