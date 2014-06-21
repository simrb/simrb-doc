require './env'

# detect the db whether connect
if Scfg[:requiredb] == 'yes'
	if DB.tables.empty?
 		Simrb.p "No database table found"
	end
end


# load modules
module_ds = []
ds = Dir["#{Sroot}modules/*"].map { |name| name.split("/").last }
ds.unshift(Scfg[:main_module])
module_ds = ds.uniq

# remove the disable modules
Scfg[:disable_modules].each do | m |
	module_ds.delete(m) if module_ds.include?(m)
end
Smodules = module_ds


# all of path for global files
Spath 				= {}
Spath[:lang] 		= []
Spath[:logic] 		= []
Spath[:tool] 		= []
Spath[:view] 		= []

Smodules.each do | name |
	Spath[:lang] 	+= Dir["#{Sroot}modules/#{name}/#{Simrb::Sdir[:lang]}/*.#{Scfg[:lang]}"]
	Spath[:logic] 	+= Dir["#{Sroot}modules/#{name}/#{Simrb::Sdir[:logic]}/*.rb"]
	Spath[:tool] 	+= Dir["#{Sroot}modules/#{name}/#{Simrb::Sdir[:tool]}/*.rb"]
	Spath[:view]	<< "#{Sroot}modules/#{name}/#{Simrb::Sdir[:view]}"
end


# caches language statement
class L
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
Spath[:lang].each do | lang |
	L << Simrb.read_file(lang)
end


# increase data and valid block
Svalid = {}
Sdata = {}
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


# alter the path of template customized 
set :views, Spath[:view]
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end


# loads main files of logics dir that would be run
Spath[:logic].each do | path |
	require path
end

