require './start'

set :run, true
set :server, Scfg[:server]
set :bind, Scfg[:bind]
set :port, Scfg[:port]

if Scfg[:environment] == 'production'
	Process.daemon
end

