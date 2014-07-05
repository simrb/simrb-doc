require 'sinatra'
require 'sinatra/base'
require 'sequel'
require 'slim'

Sroot 	= Dir.pwd + '/'
Svalid 	= {}
Sdata 	= {}

class Sl
	@@options = {}

	class << self
		def [] key
			key = key.to_s
			@@options.include?(key) ? @@options[key] : key
		end

		def << h
			@@options.merge!(h)
		end
	end
end

# increase data and valid block
module Sinatra
	class Application < Base
		def self.data name = '', &block
			(Sdata[name] ||= []) << block
		end
		def self.valid name = '', &block
			(Svalid[name] ||= []) << block
		end
	end

	module Delegator
		delegate :data, :valid
	end
end

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

		def load_module
			module_ds = {}
			Dir["#{Sroot}modules/*"].each do | path |
				path 	= "#{path}/#{Simrb::Sfile[:modinfo]}"
				content = Simrb.read_file path
				name	= content[0]["name"]
				order	= (content[0]["order"] || 99)
				module_ds[name] = order unless Scfg[:disable_modules].include?(name)
			end

			res 		= []
			module_ds	= module_ds.sort_by { |k, v| v }
			module_ds.each do | item |
				res << item[0]
			end
			res
		end

	end

	# basic definition of directory paths
	Sdir				= {
		:logic			=> 'logics',
		:store			=> 'stores',
		:lang			=> 'stores/langs',
		:docs			=> 'stores/docs',
		:schema			=> 'stores/migrations',
		:tool			=> 'stores/tools',
		:install		=> 'stores/installs',
		:view			=> 'views',
		:assets			=> 'views/assets',
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

	Sdefolder			= [:db_dir, :tmp_dir, :log_dir, :upload_dir, :backup_dir]
	Sdefcfg 			= [:lang, :db_connection, :environment, :bind, :port]

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

