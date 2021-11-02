# Task-1

![npm](https://img.shields.io/badge/ruby-v3.0.0-red)
![npm](https://img.shields.io/badge/gem-v3.2.3-green)
![npm](https://img.shields.io/badge/pg-v1.2.3-blue)
![npm](https://img.shields.io/badge/erb-v2.2.0-orange)
![npm](https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white)

This project implements a Ruby-based tool to import and store information about marketing materials and provide various kinds of reports using HTML and CSS templates. The base implementation contains a set of Ruby scripts executed through the console to create a PostgreSQL database, import data, and generate static HTML / CSS files with reports.
A more advanced layer is implemented in a rack-based application that is capable of receiving HTTP requests, uploading files, and generating reports on the fly.



# Usage
## Install
The project is written in `Ruby` language.

Before launching, you need to download certain `gems` by going to the folder `./rack_demo`

``` sh
bundler install

```

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

## Description

### Challenge 1

Contains a file with the `png` extension in which the designed database is displayed.

![db](https://user-images.githubusercontent.com/75016737/139842925-e732fcc9-5ab8-4fcd-91d7-ea5b42399c3a.png)

### Challenge 2

contains two scripts: `script_create.rb` - for creating tables of the designed database, `script_drop.rb` - for dropping.


### Challenge 3


Challenhe 1 implements the `application.rb` controller, which parses the uploaded CSV file and saves the data to the appropriate tables.

You can get to the page by the following url: ***http://127.0.0.1:9292/***

<img width="806" alt="Screenshot 2021-11-02 at 14 20 06" src="https://user-images.githubusercontent.com/75016737/139844872-a9805174-dd66-477a-b6da-62073a441b55.png">


### Challenge 4

This challenge implements the `state_report.rb` controller, which includes two classes for displaying all offices by state and offices by a certain state, respectively.

* Page for getting all offices by state: ***http://127.0.0.1:9292/reports/states***


<img width="1198" alt="Screenshot 2021-11-02 at 14 37 54" src="https://user-images.githubusercontent.com/75016737/139848158-01a1e556-f842-4e6c-a5ac-9f2a69f5e3af.png">


* Page for getting offices by a certain state: ***http://127.0.0.1:9292/reports/states/ny***

<img width="1162" alt="Screenshot 2021-11-02 at 14 35 22" src="https://user-images.githubusercontent.com/75016737/139847405-4f638b6c-6682-41ad-972f-857da58ad8a9.png">


### Challenge 5




### Challenge 6

### Challenge 7
