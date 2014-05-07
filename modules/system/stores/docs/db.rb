Sdocs['db'] =<<Doc
### mysq

	yum install mysql*
	gem install mysql
	/etc/init.d/mysqld start

 	# create database and user

	mysql -u root -p
	create user 'myuser'@'localhost' identified by '123456';
	create database mydb;
	grant all privileges on *.* to 'myuser'@'localhost' with grant option;
	granl all on mydb.* to 'myuser'@'localhost';
	quit

 	# change the password

	mysql -u root -p
	use mysql;
	update user set password=PASSWORD("new-password") where User="myuser"

	# So, the connect string of scfg file as following
	# db_connect=mysql://localhost/mydb?user=myuser&password=123456

 
### db memory

 	# mdb_connect=sqlite:/


### postgresql

	yum install postgres*
	gem install pg
	initdb -D db_pg
	postgres -D db_pg
	createdb db_pg

	# the db connect string
	# db_connect=postgres://localhost/db_pg


### sqlite

	yum install sqlite3*
	yum install sqlite-devel
	gem install sqlite3

	# db_connect=sqlite://db/data.db
Doc
