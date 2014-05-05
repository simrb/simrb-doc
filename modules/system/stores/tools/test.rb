module Simrb
	module Stool
		
		def t
			p1
			p _var(:www_home, :www)
# 			p DB[:_vars].filter(:vkey => 'sss').empty?
		end

		def t_tag
			tag = '1, 2m, 3, 4 , 5, 6, 7'
			tags = []
			[' ', ',', '+', '-'].each do | sign |
				if tag.index sign
					tags = tag.split(sign).map { |m| m.strip }
				end
			end
			p tag
			tags
		end

		def t_submit
			fkv = {:vkey => 'my', :vval => "mcccc", :tag => 'page'}
			_submit :name => :vars, :fkv => fkv
			p DB[:atag].all
			'implementing complete'
		end

		def t_log
			_log? :cms_comment, 30
			DB[:_logs].all
		end

		def t_timeout
			start_time = Time.now - 30
			_timeout? start_time, 30
		end

		def t_scfg
			Scfg
		end

		def t_tpl
# 			system_tpl_layout('cms').values[0]
#  			system_tpl_before('cms').values[0]
# 			system_tpl_var('cms').values[0]
#  			system_tpl_menu('cms').values[0]
 			system_tpl_admin('cms').values[0]
		end
		
		def t_gmc
			g_m_c :www_comments
# 			g_m_c :_user
		end
		
		def t_df
# 			_data_format :_user2_rule
			_data_format :_file
		end

		def t_menu
			DB[:_menu].all
# 			_menu :admin
		end

		def t_rule
			DB[:_rule].all
		end

		def t_vars
			DB[:_vars].all
			_var(:login, :link)
		end

		def t_root
			settings.root
		end

		def t_csv
			require 'csv'
			file_content = "work_groups\nwgid,name,descpt\n\n1,info,sss\n2,xxs,sdfsf\n3,amazon,e shop\n\n"
			res = CSV.parse(file_content)
		end

		# has the method ?
		def t_has
			self.respond_to? :t_csv
		end

		def t_env
			settings.environment
		end

		def t_file_write
			f = File.new 'tt' , 'w+'
			f.write "xxxxxxxx"
		end

		def t_argv
			p ARGV
			p ARGV.count
		end

		def t_d
#  			g_data ['demo_name', 'field1', 'field2']
#   		g_data ['demo_name', 'field1:pk', 'field2:int', 'field3:text', 'field4']
#   		g_data ['demo_name', 'field1:int=1', 'field2:int', 'field3:text', 'field4']
  			g_data ['demo_name', 'field1:pk', 'field2:int=1:label=newfieldname', 'field3:assoc_one=table,name']
		end

		def p1; puts '1'*20; end
		def p2; puts '2'*20; end
		def p3; puts '3'*20; end
		def p4; puts '4'*20; end

	end
end
