data :_mods do
	{
		:mid				=>	{
			:primary_key	=>	true,
		},
		:name				=> 	{},
		:author				=> 	{},
		:email				=> 	{},
		:website			=> 	{},
		:description		=> 	{},
		:dependon			=> 	{},
		:version			=> 	{
			:default		=>	'1.0.0'
		},
		:order				=> 	{
			:default		=>	99
		},
	}
end

data :_menu do
	{
		:mid				=>	{
			:primary_key	=>	true,
		},
		:uid				=>	{
			:default		=>	_user[:uid],
		},
		:name				=>	{},
		:link				=>	{},
		:description		=>	{},
		:parent				=>	{
			:default		=>	0,
		},
		:order				=>	{
			:default		=>	9,
		},
	}
end

data :_vars do
	{
		:vid				=>	{
			:primary_key	=>	true,
		},
		:vkey				=>	{
			:label			=>	:option,
		},
		:vval				=>	{
			:label			=>	:value,
		},
		:description		=>	{},
		:changed			=>	{
			:default		=>	Time.now
		}
	}
end

data :_file do
	{
		:fid				=>	{
			:primary_key	=>	true,
			:view_type		=>	:img
		},
		:uid				=>	{
			:default		=>	_user[:uid],
		},
		:size				=>	{},
		:type				=>	{
			:size			=>	15,
		},
		:name				=>	{},
		:path				=>	{},
		:created			=>	{
			:default		=>	Time.now
		},
	}
end

data :_mark do
	{
		:mkid				=>	{
			:primary_key	=>	true,
		},
		:name				=> 	{},
		:ip					=> 	{
			:default		=>	_ip,
			:size			=>	16,
			:type			=>	'String'
		},
		:changed			=>	{
			:default		=>	Time.now
		},
	}
end

data :_user do
	{
		:uid				=>	{
			:primary_key	=>	true,
		},
		:name				=>	{
			:size 			=>	20,
			:label			=>	:username,
		},
		:pawd				=> 	{
			:size 			=>	50,
			:form_type		=>	:password,
			:default		=>	'123456',
			:label			=>	:password,
		},
		:salt				=>	{
			:size			=>	5,
			:default		=>	_random_string(5),
		},
		:level				=>	{
			:default		=>	1,
		},
		:created			=>	{
			:default		=>	Time.now
		},
	}
end

data :_sess do
	{
		:sid				=> 	{
			:size			=>	50,
			:type			=>	'String'
		},
		:uid				=> 	{
			:default		=> 	_user[:uid],
		},
		:timeout			=> 	{
			:default		=>	30,
		},
		:ip					=> 	{
			:default		=>	_ip,
			:size			=>	16,
			:type			=>	'String'
		},
		:changed			=>	{
			:default		=>	Time.now
		},
	}
end

data :_tags do
	{
		:tid				=> 	{
			:primary_key	=>	true,
		},
		:name				=> 	{}
	}
end

data :_atag do
	{
		:atid				=> 	{
			:primary_key	=>	true,
		},
		:tid				=> 	{},
		:assoc_id			=> 	{},
		:assoc_table		=> 	{
			:type			=>	'Fixnum'
		},
	}
end

data :_docs do
	{
		:pid				=>	{
			:primary_key	=>	true
		},
		:uid				=>	{
			:form_type		=>	:hide,
			:default		=>	_user[:uid],
			:form_type		=>	:hide,
		},
		:title				=>	{},
		:body				=>	{
			:type			=>	'Text'
		},
		:created			=>	{
			:default		=>	Time.now
		},
	}
end
