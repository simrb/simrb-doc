require './env'

#######################
# load modules
#######################
module_ds = []
if Scfg[:requiredb] == 'yes'
# 	if DB.tables.include? :_mods
#  		module_ds = DB[:_mods].order(:order).map(:name)
# 	else
	if DB.tables.empty?
 		iputs ["No database table found"] 
	end
end

# merge local modules to database modules
ds = Dir["modules/*"].map { |name| name.split("/").last }
ds.unshift(Scfg[:main_module])
module_ds = ds.uniq

# remove the disable modules
Scfg[:disable_modules].each do | m |
	module_ds.delete(m) if module_ds.include?(m)
end
Smodules = module_ds

# global variables
Spath 				= {}
Spath[:lang] 		= []
Spath[:logic] 		= []
Spath[:tool] 		= []
Spath[:view] 		= []

Smodules.each do | name |
	Spath[:lang] 	+= Dir["#{Sdir}modules/#{name}/#{Sbase::Dir[:lang]}/*.#{Scfg[:lang]}"]
	Spath[:logic] 	+= Dir["#{Sdir}modules/#{name}/#{Sbase::Dir[:logic]}/*.rb"]
	Spath[:tool] 	+= Dir["#{Sdir}modules/#{name}/#{Sbase::Dir[:tool]}/*.rb"]
	Spath[:view]	<< "#{Sdir}modules/#{name}/#{Sbase::Dir[:view]}"
end

# caches language statement
class L
	@@options = {}
	class << self
		def [] key
			@@options.include?(key) ? @@options[key] : key.to_s
		end
		def << h
			@@options.merge!(h)
		end
	end
end
Spath[:lang].each do | lang |
	L << read_kv_file(lang)
end

Svalid = {}
Sdata = {}
# add block of data and valid
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

# custom template path
set :views, Spath[:view]
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

# loads the files that would be run
Spath[:logic].each do | f |
	require f
end

