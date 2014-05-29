## A simple way to build your application with ruby


### Preparation

Make sure your git and database would be setup first.

installing ruby
	
	$ \curl -sSL https://get.rvm.io | bash -s stable
	# rvm install ruby-1.9.2

installing git

	$ yum install git

installing database

assuming the database is sqlite, you should type the commands to install it as following

	# yum install sqlite3*
	# yum install sqlite-devel

now, the database connection is `sqlite://db/data.db` that would be used as below,
more database installation please see modules/system/stores/docs/db.rb


#### Installation

	$ gem install simrb
	$ simrb init myapp
	$ cd myapp
	$ echo 'db_connect=sqlite://db/data.db' > scfg

bundle the running environment as you want

	$ bundle install --gemfile=modules/system/stores/Gemfile --without=production
or
	$ bundle install --gemfile=modules/system/stores/Gemfile --without=develpment

	$ 3s install


### Starting

Assuming the default web server is thin

	ruby thin.rb

further more, check the port whether it is used

	netstat -apn

add port for ip4

	# vi /etc/sysconfig/iptables

write

	-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT

restart it

	# /etc/init.d/iptables restart


### Extending

Extending your application with modules of offical repository, just enter the project root dir, then

	$ 3s clone repo_name/project_name


### Community

[issue](https://github.com/simrb/simrb/issues)
