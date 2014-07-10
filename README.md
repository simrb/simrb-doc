## A simple way to build your application with ruby


### Preparation

If this is not the first time to install simrb, please ignore this environment configure, just jump to the part of installation directly.

installing ruby

	$ \curl -sSL https://get.rvm.io | bash -s stable
	# rvm install ruby-2.1.2

installing git

	$ yum install git

installing database, assuming the database is sqlite, you should type the commands to install it as following

	# yum install sqlite3*
	# yum install sqlite-devel

now, the database connection is `sqlite://db/data.db` that would be used as below,
more database installation please see `modules/system/boxes/docs/db.rb`

about web server environment, check the port 80 whether it has been used yet

	netstat -apn | grep :80

normally, you need to remove the apache because the httpd always occupy the port 80 if it exists

	# yum remove httpd

reset the port for our server

	# iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
	# service iptables save
	# service iptables restart


### Installation

	$ gem install simrb

initialize a project copy with development mode, the default insatlling without option --dev that is production mode

	$ simrb init myapp --dev

	$ cd myapp
	$ echo 'db_connection: sqlite://db/data.db' > scfg

	$ 3s install


### Starting

Assuming the default web server is thin, so we start by

	ruby thin.rb


### Extending

Extending your application with modules getting from offical repository, fetch by command

	$ 3s clone repo_name/project_name


### Community

[issue](https://github.com/simrb/simrb/issues)
