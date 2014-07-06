require './env'

# load config file
unless File.exist? 'scfg'
	data = {}
	Simrb::Scfg[:init_self].each do | opt |
		data[opt] = Scfg[opt]
	end
	Simrb.write_file('scfg', data)
end

Scfg = Simrb::Scfg
Simrb.read_file('scfg').each do | k, v |
	Scfg[k.to_sym] = v
end

# initialize default directories
Scfg[:dirs].each do | name, path |
	if !Scfg[:uninit_dirs].include?(name) and !File.exist?(path)
		if path[-1] == '/'
			Dir.mkdir(path) 
		else
			File.open(path, 'w+') do | f |
				f.write("")
			end
		end
	end
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
Sload 				= {}
Sload[:lang] 		= []
Sload[:logic] 		= []
Sload[:tool] 		= []
Sload[:view] 		= []

Smodules.each do | name |
	Sload[:lang] 	+= Dir["#{Sroot}modules/#{name}/#{Simrb::Spath[:lang]}*.#{Scfg[:lang]}"]
	Sload[:logic] 	+= Dir["#{Sroot}modules/#{name}/#{Simrb::Spath[:logic]}*.rb"]
	Sload[:tool] 	+= Dir["#{Sroot}modules/#{name}/#{Simrb::Spath[:tool]}*.rb"]
	Sload[:view]	<< "#{Sroot}modules/#{name}/#{Simrb::Spath[:view]}".chomp("/")
end

# cache label statement of language
Sload[:lang].each do | lang |
	Sl << Simrb.read_file(lang)
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

# load main files in logic directory that will be run later
Sload[:logic].each do | path |
	require path
end

