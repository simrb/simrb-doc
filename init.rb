require './env'

# load config file
unless File.exist? 'scfg'
	data = {}
	Simrb::Sdefcfg.each do | opt |
		data[opt] = Scfg[opt]
	end
	Simrb.write_file('scfg', data)
end

Scfg = Simrb::Scfg
Simrb.read_file('scfg').each do | k, v |
	Scfg[k.to_sym] = v
end

# initialize default directories
Simrb::Sdefolder.each do | dir |
	Dir.mkdir Scfg[dir] unless File.exist? Scfg[dir]
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

# cache label statement of language
Spath[:lang].each do | lang |
	Sl << Simrb.read_file(lang)
end

# load main files in logic directory that will be run later
Spath[:logic].each do | path |
	require path
end

