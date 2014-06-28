require 'sinatra'
require 'sinatra/base'
require 'sequel'
require 'slim'


Sroot = Dir.pwd + '/'
module Simrb

	# common methods
	class << self

		def read_file path
			require 'yaml'
			YAML.load_file path
		rescue
			[]
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

	# basic definition of directory paths
	Sdir				= {
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

	# basic definition of files
	Sfile				= {
		:route			=> 'logics/routes.rb',
		:gemfile		=> 'stores/Gemfile',
		:modinfo		=> 'stores/installs/_mods',
		:readme			=> 'README.md',
		:vars			=> 'stores/installs/_vars',
		:menu			=> 'stores/installs/_menu',
	}

	# dirs to be generated in initializing module
	Sdefdir				= [:logic, :store, :view, :assets, :lang, :install, :docs, :schema, :tool]

	# files to be generated in initializing module
	Sdefile				= [:route, :gemfile, :modinfo, :readme]

	# basic definition of assets file path
	Sdoc				= {
		:layout_css		=> 'stores/docs/layout.css',
		:common_css		=> 'stores/docs/common.css',
	}

	# default settings of scfg file
	Scfg				= {
		:requiredb			=> 'yes',
		:main_module		=> 'system',
		:disable_modules	=> [],
		:encoding			=> 'utf-8',
		:lang				=> 'en',
		:install_lock		=> 'yes',
		:db_connection		=> 'sqlite://db/data.db',
		:db_dir				=> Sroot + 'db',
		:upload_dir			=> Sroot + 'db/upload/',
		:backup_dir			=> Sroot + 'db/backup/',
		:tmp_dir			=> Sroot + 'tmp',
		:log_dir			=> Sroot + 'log',
		:server_log			=> Sroot + 'log/thin.log',
		:command_log		=> Sroot + 'log/command_error_log.html',
		:server_log_mode	=> 'file',
		:cache_dir			=> '/var/cache/simrb/',
		:time_types			=> ['created', 'changed'],
		:fixnum_types		=> ['order', 'level'],
		:number_types 		=> ['Fixnum', 'Integer', 'Float'],
		:environment 		=> 'development',	# or production, test
		:server 			=> 'thin',
		:bind 				=> '0.0.0.0',
		:port				=> 3000,
	}

	# alias of field type 
	Salias				=	{
		:int 				=> 'Fixnum',
		:str 				=> 'String',
		:text 				=> 'Text',
		:time				=> 'Time',
		:big				=> 'Bignum',
		:fl					=> 'Float',
	}

end


# load the scfg file
unless File.exist? 'scfg'
	data = {}
	[:lang, :db_connection, :environment, :bind, :port].each do | opt |
		data[opt] = Scfg[opt]
	end
	Simrb.write_file('scfg', data)
end

Scfg = Simrb::Scfg
Simrb.read_file('scfg').each do | k, v |
	Scfg[k.to_sym] = v
end


# default directories initializing
[:db_dir, :tmp_dir, :log_dir, :upload_dir, :backup_dir].each do | dir |
	Dir.mkdir Scfg[dir] unless File.exist? Scfg[dir]
end


# default environment and db configuration setting
set :environment, Scfg[:environment].to_sym

configure do
	DB = Sequel.connect(Scfg[:db_connection])
end

configure :production do
	not_found do
		L['sorry, no page']
	end

	error do
		L['sorry there was a nasty error - '] + env['sinatra.error'].name
	end
end

