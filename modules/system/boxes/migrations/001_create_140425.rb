Sequel.migration do
	change do
		create_table(:_mods) do
			primary_key :mid
			String :name
			String :author
			String :email
			String :website
			String :description
			String :dependon
			String :version
			Fixnum :order
		end
		create_table(:_menu) do
			primary_key :mid
			Fixnum :uid
			String :name
			String :link
			String :description
			Fixnum :parent
			Fixnum :order
		end
		create_table(:_vars) do
			primary_key :vid
			String :vkey
			String :vval
			String :description
			Time :changed
		end
		create_table(:_file) do
			primary_key :fid
			Fixnum :uid
			String :size
			String :type, :size => 15
			String :name
			String :path
			Time :created
		end
		create_table(:_mark) do
			primary_key :mkid
			String :name
			String :ip, :size => 16
			Time :changed
		end
		create_table(:_user) do
			primary_key :uid
			String :name, :size => 20
			String :pawd, :size => 50
			String :salt, :size => 5
			Fixnum :level
			Time :created
		end
		create_table(:_sess) do
			String :sid, :size => 50
			Fixnum :uid
			Fixnum :timeout
			String :ip, :size => 16
			Time :changed
		end
		create_table(:_tags) do
			primary_key :tid
			String :name
		end
		create_table(:_atag) do
			primary_key :atid
			Fixnum :tid
			Fixnum :assoc_id
			Fixnum :assoc_table
		end
		create_table(:_docs) do
			primary_key :pid
			Fixnum :uid
			String :title
			Text :body
			Time :created
		end
	end
end
