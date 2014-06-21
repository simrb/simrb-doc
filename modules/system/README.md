# INTRODUCTION

It is a core module of simrb that defines the essential things for extending other application modules.


## RESPONSIBILITY DEFINITION ABOUT SYSTEM MODULE

This existed purpose of the module is to construct a strong background, and fundamental function.
The base construction includes several little system, such as the database tables defined, common function helpers, etc.


### DATABASE TABLES

	mods - store the module information

	menu - all of link collection

	vars - system variables for setting options

	file - media files

	mark - record the status of operation action

	user - user, just user account, password, and so on

	sess - session, record the user sesssion

	docs - a simple way to store data

	tags - strong content catalog for everything, anything above

	atag - association tags of any content to be association one or more tags that will be saved here


### TAG SYSTEM

The db table, and everything could be classified by one tag or more, including itself. So, the tag system is necessary for anything.

