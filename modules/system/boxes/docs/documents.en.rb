Sdocs['About us'] =<<Doc

Issue:		https://github.com/simrb/system/issues
Email:		coolesting@gmail.com
Doc



Sdocs['Basic structure'] =<<Doc

	base - establish the basic element for creating your application

	data - input and process the data that interconnects with database

	view - display the data with any views, like table, form

	menu - create, insert, update menu data

	file - upload file, send file

	user - user login, register, info stored, allow to access certain app

	admin - a dashboard view to administer the data

	vars - save variable to database for settings

	tags - mark any datas with tag that lets you avoid classifiing data each time
Doc



Sdocs['Available commands'] =<<Doc
	this is one
Doc



Sdocs['Configuration, main application, controler'] =<<Doc
Doc



Sdocs['Data, model, database'] =<<Doc
Doc



Sdocs['View, template'] =<<Doc
Doc



Sdocs['Misc, installing database'] =<<Doc
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

