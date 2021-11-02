# Task-1

![npm](https://img.shields.io/badge/ruby-v3.0.0-red)
![npm](https://img.shields.io/badge/gem-v3.2.3-green)
![npm](https://img.shields.io/badge/pg-v1.2.3-blue)
![npm](https://img.shields.io/badge/erb-v2.2.0-orange)

This project implements a Ruby-based tool to import and store information about marketing materials and provide various kinds of reports using HTML and CSS templates. The base implementation contains a set of Ruby scripts executed through the console to create a PostgreSQL database, import data, and generate static HTML / CSS files with reports.
A more advanced layer is implemented in a rack-based application that is capable of receiving HTTP requests, uploading files, and generating reports on the fly.



# Usage
## Install
The project is written in `Ruby` language.

Before launching, you need to download certain `gems` by going to the folder `./rack_demo`

``` sh
bundler install

```

## How to use

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

# Description

## Challenge 1

Contains a file with the `png` extension in which the designed database is displayed.

![db](https://user-images.githubusercontent.com/75016737/139842925-e732fcc9-5ab8-4fcd-91d7-ea5b42399c3a.png)

## Challenge 2

contains two scripts: `script_create.rb` - for creating tables of the designed database, `script_drop.rb` - for dropping.


## Challenge 3


Challenhe 1 implements the `application.rb` controller, which parses the uploaded CSV file and saves the data to the appropriate tables.

You can get to the page by the following url: ***http://127.0.0.1:9292/***

<img width="806" alt="Screenshot 2021-11-02 at 14 20 06" src="https://user-images.githubusercontent.com/75016737/139844872-a9805174-dd66-477a-b6da-62073a441b55.png">


## Challenge 4

This challenge implements the `state_report.rb` controller, which includes two classes for displaying all offices by state and offices by a certain state, respectively.

* Page for getting all offices by state: ***http://127.0.0.1:9292/reports/states***


<img width="1198" alt="Screenshot 2021-11-02 at 14 37 54" src="https://user-images.githubusercontent.com/75016737/139848158-01a1e556-f842-4e6c-a5ac-9f2a69f5e3af.png">


* Page for getting offices by a certain state: ***http://127.0.0.1:9292/reports/states/ny***

<img width="1162" alt="Screenshot 2021-11-02 at 14 35 22" src="https://user-images.githubusercontent.com/75016737/139847405-4f638b6c-6682-41ad-972f-857da58ad8a9.png">


## Challenge 5

The `fixture_reports.rb` controller implements the output of all offices of a certain fixture type and the output of all fixtures types for a specific office:
 
* Page for getting all offices for all fixtures type: ***http://127.0.0.1:9292/reports/offices/fixture_types***

<img width="1209" alt="Screenshot 2021-11-02 at 18 54 39" src="https://user-images.githubusercontent.com/75016737/139910388-e078dca1-70cb-4c57-9284-3124a28f20c9.png">


* Page for getting all fixtures type for a specific office: ***http://127.0.0.1:9292/reports/offices/1/fixture_types***

<img width="1177" alt="Screenshot 2021-11-02 at 18 55 57" src="https://user-images.githubusercontent.com/75016737/139910526-b7d8bdd6-0e8a-4304-ab4c-01fc6a0e3004.png">


## Challenge 6

The `marketing_materials.rb` controller implements the output of all marketing materials for each office. The donut diagram is also displayed in the template after each report.

* Url: ***http://127.0.0.1:9292/reports/offices/marketing_materials***

<img width="1199" alt="Screenshot 2021-11-02 at 19 08 21" src="https://user-images.githubusercontent.com/75016737/139912489-ec9309a8-5374-4d05-b5db-b4b3b777ab26.png">


## Challenge 7

Two classes are implemented in the office_installation.rb controller. The first OfficeInstallationRoot is responsible for displaying all links to offices, it also displays the search string for full-text search for the address and title fields.

* Url for the OfficeInstallationRoot: ***http://127.0.0.1:9292/reports/offices/installation***

<img width="1149" alt="Screenshot 2021-11-02 at 19 20 00" src="https://user-images.githubusercontent.com/75016737/139914232-6b680aba-b62a-41b6-a7d7-35b89c3aa521.png">


The second class displays data about the office with a specific ID from the url parasets.

* Url for the OfficeInstallation: ***http://127.0.0.1:9292/reports/offices/1/installation***

<img width="1204" alt="Screenshot 2021-11-02 at 19 20 38" src="https://user-images.githubusercontent.com/75016737/139914328-af307479-4a5a-4d2b-9184-77cdfd2d3c3e.png">


# License

