require './env'

# load config file
unless File.exist? 'scfg'
	data = {}
	Simrb::Scfg[:init_self].each do | opt |
		data[opt] = Simrb::Scfg[opt]
	end
	Simrb.yaml_write('scfg', data)
end

Scfg = Simrb::Scfg
Simrb.yaml_read('scfg').each do | k, v |
	Scfg[k.to_sym] = v
end

# load patn
Spath = Simrb::Spath

# initialize default directories
Scfg[:init_dir_path].each do | item |
	path = "#{Spath[item]}"
	Simrb::path_init path
end

# detect database connection
if Scfg[:requiredb] == 'yes'
	if Sequel.connect(Scfg[:db_connection]).tables.empty?
 		Simrb.p "No database table found"
	end
end

# load modules
Smodules = Simrb.load_module

# scan file path
Sload[:lang] 		= []
Sload[:main] 		= []
Sload[:tool] 		= []
Sload[:view] 		= []

Smodules.each do | name |
	Sload[:lang] 	+= Dir["#{Spath[:module]}#{name}#{Spath[:lang]}*.#{Scfg[:lang]}"]
	Sload[:tool] 	+= Dir["#{Spath[:module]}#{name}#{Spath[:box]}*.rb"]
	Sload[:main] 	+= Dir["#{Spath[:module]}#{name}/*.rb"]
	Sload[:view]	<< "#{Spath[:module]}#{name}#{Spath[:view]}".chomp("/")
end

# cache label statement of language
Sload[:lang].each do | lang |
	Sl << Simrb.yaml_read(lang)
end

# default environment and db configuration setting
set :environment, Scfg[:environment].to_sym

# alter the path of template customized 
set :views, Sload[:view]
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

# load main files that will be run later
Sload[:main].each do | path |
	require path
end

