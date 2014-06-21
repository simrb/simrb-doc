get '/admin/info' do
	admin_page :admin_info
end

get '/admin/userinfo' do
	admin_page :admin_info
end

get '/admin/tag' do
	admin_page :admin_info
end

get '/admin/mods' do
	_admin :_mods
end

get '/admin/menu' do
	_admin :_menu
end

get '/admin/vars' do
	_admin :_vars
end

get '/admin/tags' do
	_admin :_tags
end

get '/admin/atag' do
	_admin :_atag
end

get '/admin/docs' do
	_admin :_docs
end

get '/admin/user' do
	_admin(
		:_view_		=>	{
			:name		=>	:_user,
			:_method_	=>	'_user_edit_',
			:fields		=>	[:uid, :name, :level, :created],
			:search_fns	=>	[:uid, :name, :level, :created],
			:btn_fns	=>	{ :create => '_user_add_' },
			:opt_fns 	=> 	{ :delete => '_user_del_' },
		},
		:_form_		=>	{
			:name		=>	:_user,
			:fields		=>	[:pawd, :level],
			:_method_	=>	'_user_edit_',
		}
	)
end

get '/admin/mark' do
	_admin :_mark
end

get '/admin/sess' do
	_admin(
		:_view_		=>	{
			:name		=>	:_sess,
			:opt_fns 	=>	{
				:delete 		=> '_rm_',
				:delete_all 	=> '_session_clean_all_',
				:delete_timeout => '_session_clean_timeout_',
			},
		},
		:_form_		=>	{
			:name		=>	:_sess,
		}
	)
end

########################################################
# file
########################################################
get '/admin/file' do
	_admin(
		:_view_		=>	{
			:name		=>	:_file,
			:btn_fns	=> { :create => '_file_create_' }, #edit template
			:opt_fns	=> { :delete => '_file_del_' },
			:lnk_fns	=> {},
		},
		:_form_		=>	{
			:name		=>	:_file,
		}
	)
end

post '/admin/file' do
	if params[:upload]
		params[:upload].each do | p |
			_file_save p
		end
		_msg L[:'upload complete']
	else
		_msg L[:'the file is null']
	end
	redirect back
end


########################################################
# backup
########################################################
get '/admin/baks' do
	if @qs[:opt] == 'export'
		if @qs[:id]
			type = @qs[:id].split('_').last
			send_file Scfg[:backup_dir] + @qs[:id], :filename => "#{@qs[:id]}.#{type}", :type => type.to_sym
# 		attachment "#{Time.now}.csv"
# 		csv_file
		end
	elsif @qs[:opt] == 'recover'
		_backup_recover(@qs[:id], @qs[:encoding]) if @qs[:id]
		_msg L[:'recover complete']
		redirect back
	elsif @qs[:opt] == 'delete'
		file = File.delete Scfg[:backup_dir] + "#{@qs[:id]}"
		_msg L[:'delete complete']
		redirect back
	else
		@tables = DB.tables
		@encoding = _var(:encoding, :file) != "" ? _var(:encoding, :file) : Scfg[:encoding]
		admin_page :_backup
	end
end

#backup
post '/admin/baks/backup' do
	if params[:table_name]
		#generate the csv file
		encoding 	= params[:encoding] ? params[:encoding] : _var(:encoding, :file)
		csv_file 	= _table_to_csv params[:table_name], encoding
		filename	= (params[:filename] and params[:filename] !='') ? params[:filename] : 'Records'
		filename 	= Scfg[:backup_dir] + "#{filename}_#{Time.now.strftime('%y%m%d_%H%M%S')}_csv"

		#save at server
		File.open(filename, 'w+') do | f |
			f.write csv_file
		end
		_msg L[:'backup complete']
	end
	redirect back
end

#inport
post '/admin/baks/inport' do
	if params[:inport] and params[:inport][:tempfile]
		filename = params[:inport][:filename].split('.').first
		File.open(Scfg[:backup_dir] + filename, 'w+') do | f |
			f.write params[:inport][:tempfile].read
		end
		_msg L[:'upload complete']
	end
	redirect back
end


helpers do

	def _view_ argv = {}
		argv[:layout] 		||= :admin_layout
		argv[:title] 		||= _var(:title, :page)
		argv[:keywords]		||= _var(:keywords, :page)
		argv[:description]	||= _var(:description, :page)
		_view argv
	end

	def _form_ argv = {}
		argv[:layout] 		||= :admin_layout
		argv[:title] 		||= _var(:title, :page)
		argv[:keywords]		||= _var(:keywords, :page)
		argv[:description]	||= _var(:description, :page)
		_form argv
	end

	def _submit_ argv = {}
		_submit argv
	end

	def admin_page name
		@t[:title] 			||= _var(:admin_title, :admin_page)
		@t[:keywords]		||= _var(:keywords, :admin_page)
		@t[:description]	||= _var(:description, :admin_page)
		_tpl name, :admin_layout
	end

	def _admin options = {}
		# add the rule _rule? :admin
		method = @qs.include?(:_method_) ? @qs[:_method_] : '_view_'

		# if the options is a symbol , it will be changed to a hash
		#
		# == Example
		# such as, :tags symbol, will be the following
		# {_view_ => {:name => :tags}, :_form_ => {:name => :tags}}
		if options.class.to_s == 'Symbol'
			options = {:_view_ => {:name => options}, :_form_ => {:name => options}}
		end

		argv = options.include?(method.to_sym) ? options[method.to_sym] : {}
		if method and method[-1] == '_' and self.respond_to?(method.to_sym)
			eval("#{method} argv")
		end
	end

	def _user_add_ argv = {}
		argv = params if params[:name] and params[:pawd]
		if argv[:name] and argv[:pawd]
			_user_add argv
		else
			_form_ :name => :_user, :fields => [:name, :pawd, :level], :_method_ => '_user_add_'
		end
	end

	def _user_del_ argv = {}
		if params[:uid]
			params[:uid].each do | uid |
				_user_del uid.to_i
			end
		end
	end

	def _file_create_ argv = {}
		admin_page :_file_form
	end

	def _file_del_ argv = {}
		if params[:fid]
			params[:fid].each do | fid |
				_file_rm fid
			end
		end
	end

	def _table_to_csv datas, encoding = nil
		require 'csv'
		csv_file 	= ''
		tables 		= DB.tables

		datas.each do | tn |
			table_name = tn.to_sym
			if tables.include?(table_name)
				ds = DB[table_name]
				res = CSV.generate do | csv |
					csv << [table_name, '###table###']
					csv << (DB[table_name].columns! + ['##fields##'])
					csv << []
					ds.each do | row |
						csv << row.values
					end
					csv << []
				end
				csv_file << res
			end
		end

		encoding == nil ? csv_file : csv_file.force_encoding(encoding)
	end

	def _backup_recover id, encoding = nil
		file = File.read Scfg[:backup_dir] + "#{id}"

		#encoding
# 		unless encoding == nil
		file.force_encoding 'UTF-8'
# 		end

		require 'csv'
		contents = CSV.parse(file)

		#split the contents with '##########' to many block. each block is a table data
		contents.each do | row |
			if row.last == '###table###'
				@table		= row[0].to_sym

			elsif row.last == '##fields##'
				row.pop
				@tb_fields	= row
				@db_fields	= DB[@table].columns

			else
				unless row.empty?
					data = {}
					row.each_index do | i |
						if @db_fields.include? @tb_fields[i].to_sym
							data[@tb_fields[i].to_sym] = row[i]
						end
					end
					DB[@table].insert(data)
				end

			end
		end
	end

	def _fetch_backup_list
		res = []
		Dir[Scfg[:backup_dir] + '*'].each do | f |
			res << f.split('/').last
		end
		res.sort.reverse
	end

end
