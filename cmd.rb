# ####################
# booting for command mode
# ####################
require './init'

# loads the documentations
Sdocs = {}
Smodules.each do | name |
	Dir["#{Sdir}modules/#{name}/#{Simrb::Dir[:docs]}/*.rb"].each do | path |
		require path
	end
end

def puts_doc args = []
	args.shift 1
	unless args.empty?
		name = args.join ' '
		if Sdocs[name].class.to_s == 'Array'
			res = Sdocs[name].join("\n")
		else
			res = Sdocs[name].to_s
		end
		Simrb.p res
	end
end

# display the doc
if ARGV[0] == 'doc' and ARGV.count > 1
	puts_doc ARGV.clone
	exit
end


# loads the bash commands of tools
Spath[:tool].each do | f |
	require f
end

helpers do
	include Simrb::Stool
end

get '/_tools' do
	argv = ARGV.clone
	if Simrb::Stool.method_defined? argv[0]
		argv.shift 1
		if argv.empty?
			eval(ARGV[0]).to_s
		else
 			eval("#{ARGV[0]} #{argv}").to_s
		end
	else
		"Sorry, no command ' #{ARGV[0]} ' we found."
	end
end

output = []

if ARGV[0]
	env = {'PATH_INFO' => "/_tools", 'REQUEST_METHOD' => 'GET', 'rack.input' => ''}
	status, type, body = Sinatra::Application.call env
	if status == 200
		body.each do | res |
			output << res
		end
	else
		path = "log/command_error_log.html"
		File.open(path, 'a+') do |f|
			f.write "\n\n\n#{'='*5}\n#{Time.now.to_s}\n"
			f.write body
		end
		output << env["sinatra.error"]
	end
else
	output << "You need a argument at least."
end

Simrb.p output
