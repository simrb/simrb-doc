# ####################
# booting for command mode
# ####################
require './init'

Spath[:tool].each do | path |
	require path
end
argv = ARGV.clone
output = []

# command mode
if argv.count > 0 and Simrb::Stool.method_defined?(argv[0])

	helpers do
		include Simrb::Stool
	end

	get '/_tools' do
		method = argv.shift(1)[0]
		argv.empty? ? eval(method).to_s : eval("#{method} #{argv}").to_s
	end

	env = {'PATH_INFO' => "/_tools", 'REQUEST_METHOD' => 'GET', 'rack.input' => ''}
	status, type, body = Sinatra::Application.call env
	if status == 200
		body.each do | line |
			output << line
		end
	else
		File.open(Scfg[:command_log], 'a+') do |f|
			f.write "\n#{'='*20}#{Time.now.to_s}\n#{'='*20}\n"
# 			f.write body
			f.write Sinatra::ShowExceptions.new(self).call(env.merge("HTTP_USER_AGENT" => "curl"))[2][0]
		end
		output << env["sinatra.error"]
	end

# document mode
else

	Sdocs = {}
	argv.shift 1 

	Smodules.each do | name |
		Dir["#{Sroot}modules/#{name}/#{Simrb::Sdir[:docs]}/*.#{Scfg[:lang]}.rb"].each do | path |
			require path
		end
	end

	i = 0
	docs_key = {}
	docs_val = {}
	Sdocs.each do | key, val |
		docs_key[i] = key
		docs_val[i] = val
		i = i + 1
	end

	if argv.empty?
		output << L['please select the number before the ducumentation to see detials, like $ 3s doc 0']
		docs_key.each do | i, key |
			output << "#{i.to_s}, #{key}"
		end
	else
		argv.each do | i |
			output << (docs_val.include?(i.to_i) ? docs_val[i.to_i] : L['no document'])
		end
	end

end

Simrb.p output
