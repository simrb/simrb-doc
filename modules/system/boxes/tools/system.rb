module Simrb
	module Stool
		
		# for installation

		def system_install_before
		end

		def system_install_after
		end

		def _user_installer data
			data.each do | h |
				_user_add h
			end
		end

		def _menu_installer data
			data.each do | h |
				_menu_add h
			end
		end

		def _vars_installer data
			data.each do | h |
				_var_add h
			end
		end

	end
end

