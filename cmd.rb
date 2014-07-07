# ####################
# booting for command mode
# ####################
require './init'

Sload[:tool].each do | path |
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
		File.open(Spath[:command_log], 'a+') do | f |
			f.write "\n#{'='*10}#{Time.now.to_s}\n#{'='*10}\n"
# 			f.write body
 			f.write (Sinatra::ShowExceptions.new(self).call(env.merge("HTTP_USER_AGENT" => "curl"))[2][0].to_s + "\n")
		end
		output << env["sinatra.error"]
	end

# document mode
else

	Sdocs = {}
	argv.shift 1 

	Smodules.each do | name |
		Dir["#{Spath[:module]}#{name}#{Spath[:docs]}*.#{Scfg[:lang]}.rb"].each do | path |
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
		output << Sl['please select the number before the list to see detials, like $ 3s doc 2']
		docs_key.each do | i, key |
			output << "#{i.to_s}, #{key}"
		end
	else
		argv.each do | i |
			output << (docs_val.include?(i.to_i) ? docs_val[i.to_i] : Sl['no document'])
		end
	end

end

Simrb.p output
