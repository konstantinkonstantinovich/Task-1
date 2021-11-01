# Task-1

![npm](https://img.shields.io/badge/ruby-v3.0.0-red)
![npm](https://img.shields.io/badge/gem-v3.2.3-green)

This project implements a Ruby-based tool to import and store information about marketing materials and provide various kinds of reports using HTML and CSS templates. The base implementation contains a set of Ruby scripts executed through the console to create a PostgreSQL database, import data, and generate static HTML / CSS files with reports.
A more advanced layer is implemented in a rack-based application that is capable of receiving HTTP requests, uploading files, and generating reports on the fly.



# Usage
## Install
The project is written in `Ruby` language.

In order to start the project, you need to run a several of commands:

* To create tables in the database, go to the `./Challenge 2` folder and run:

```
ruby script_create.rb

```
* To delete tables, you need to run:

```sh
ruby script_drop.rb

```

* To start rack app get to `./Challenge 3/rack_demo` folder and run:

```sh
rackup

```
