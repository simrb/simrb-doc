require './init'

set :run, true
set :server, Scfg[:server]
set :bind, Scfg[:bind]
set :port, Scfg[:port]

if Scfg[:environment] == 'production'
	Process.daemon

	if Scfg[:server_log_mode] == 'file'
		log = File.new(Scfg[:server_log], "a+") 
		$stdout.reopen(log)
		$stderr.reopen(log)

		$stderr.sync = true
		$stdout.sync = true
	end
end
