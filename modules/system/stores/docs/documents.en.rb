Sdocs['About us, support, contact'] =<<Doc
please go to https://github.com/simrb/simrb/issues
Doc


Sdocs['How to create a module ?'] =<<Doc
################
# Setp 1
################

initialize a module directory whatever you want to do for your new applications

	$ 3s new blog

the result generated like below

blog
-- logics/
-- -- routes.rb
-- stores/
-- -- installs/
-- -- langs/
-- -- migrations/
-- -- tools/
-- -- docs/
-- -- Gemfile
-- views/
-- -- assets/
-- README.md

################
# Setp 2
################

What should i do to these directories

Doc


Sdocs['How to install database ?'] =<<Doc
################
# mysql
################

	yum install mysql*
	gem install mysql
	/etc/init.d/mysqld start

create database and user

	mysql -u root -p
	create user 'myuser'@'localhost' identified by '123456';
	create database mydb;
	grant all privileges on *.* to 'myuser'@'localhost' with grant option;
	granl all on mydb.* to 'myuser'@'localhost';
	quit

change the password

	mysql -u root -p
	use mysql;
	update user set password=PASSWORD("new-password") where User="myuser"

So, the connection string as below, replace the db_connection value of scfg file with it 
mysql://localhost/mydb?user=myuser&password=123456

 
################
# db memory
################

the string like this, sqlite:/


################
# postgresql
################

	yum install postgres*
	gem install pg
	initdb -D db_pg
	postgres -D db_pg
	createdb db_pg

the db connection string, like postgres://localhost/db_pg


################
# sqlite
################

	yum install sqlite3*
	yum install sqlite-devel
	gem install sqlite3

string connection like, sqlite://db/data.db
Doc

