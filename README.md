## A simple way to create your application with ruby

### Installation
	
	# Step 1, get it from repository

	git clone git://github.com/simrb/simrb.git myapp

	# Step 2, if you first time to install, run the command for initializing
	( add alias to ~/.bashrc file)

	cd myapp && ruby cmd.rb init

	# Step 3, connect to db, and install
	# put this option db_connect=your_db_path to your scfg file, details at `$3s doc db`

	$3s install

### Extending with modules

	clone it from github
	
	$3s clone simrb/cms

### Starting by thin

	thin start -a 0.0.0.0 -p 80

	or, run at background

	thin start -a 0.0.0.0 -p 80 -d

