## A simple way to create your application with ruby

### Installation

Step 0, install ruby and git
	
	$ yum install git
	$ \curl -sSL https://get.rvm.io | bash -s stable

Step 1, get it from repository

	$ git clone https://github.com/simrb/simrb.git myapp

add a command alias to bashrc file

	echo 'alias 3s="ruby cmd.rb"' >> ~/.bashrc && source

Step 2, connect database, assuming the default database is sqlite, you should do as following, if you have the existed database, ignore this step

	# yum install sqlite3*
	# yum install sqlite-devel

and put the connection to configure file

	echo 'db_connect=sqlite://db/data.db' > scfg

more database installation please see modules/system/stores/docs/db.rb

Step 3, install gems

	$ bundle install --gemfile=modules/system/stores/Gemfile --without=production

Step 4, install simrb

	$ 3s install


### Booting

assuming your server is thin

	thin start -a 0.0.0.0 -p 80

or, run at background

	thin start -a 0.0.0.0 -p 80 -d

further more, check the port whethe it is used

	netstat -apn

add port for ip4

	# vi /etc/sysconfig/iptables

add

	-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT

restart

	# /etc/init.d/iptables restart


### Extending

Extending your application with modules

	$3s clone repo_name/project_name

