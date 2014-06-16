# ####################
# booting for command mode
# ####################
require './init'

argv = ARGV.clone
output = []
if ARGV.count > 0
	cmd = ARGV[0]

	# document mode
	if cmd == 'doc'
		Sdocs = {}
		argv.shift 1 

		Smodules.each do | name |
			Dir["#{Sdir}modules/#{name}/#{Simrb::Dir[:docs]}/*.rb"].each do | path |
				require path
			end
		end

		unless argv.empty?
			name = argv.join ' '
			output = Sdocs.include?(name) ? Sdocs[name] : "No document called #{name}"
		end

	# command mode
	elsif Simrb::Stool.method_defined?(cmd)
		
		Spath[:tool].each do | path |
			require path
		end

		helpers do
			include Simrb::Stool
		end

		get '/_tools' do
			argv = ARGV.clone
			argv.shift 1
			argv.empty? ? eval(ARGV[0]).to_s : eval("#{ARGV[0]} #{argv}").to_s
		end

		env = {'PATH_INFO' => "/_tools", 'REQUEST_METHOD' => 'GET', 'rack.input' => ''}
		status, type, body = Sinatra::Application.call env
		if status == 200
			body.each do | line |
				output << line
			end
		else
			File.open(Scfg[:command_log], 'a+') do |f|
				f.write "\n\n\n#{'='*5}\n#{Time.now.to_s}\n"
				f.write body
			end
			output << env["sinatra.error"]
		end

	else
		output = "Sorry, no command ' #{ARGV[0]} ' we found."
	end

else
	output = "Hi, guy, typing something, like $3s doc db"
end

Simrb.p output
