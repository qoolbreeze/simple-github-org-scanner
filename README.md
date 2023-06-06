# simple-github-org-scanner

## Description

This repository contains a bash script that scan github organzation in order to look at secrets contains inside source code.

## Requirements

The requirements are the following:

* Having a token that can download repositories in the github organizatio
* Having a linux system with python version 3 installed (testing on Debian 11)

## Installation

You can run the following command to install the requirements:

```sh
sudo apt update
sudo apt install python3 python3-pip git
pip3 install detect-secrets
```

You can run the following command to install the application:

```sh
git clone git@github.com:qoolbreeze/simple-github-org-scanner.git
cd simple-github-org-scanner
chmod +x simple-secret-scanner.sh
```

## Run the application

The application required the following input:

* $1 : github token value
* $2 : github organization name

Sample:

```bash
./simple-secret-scanner.sh <token> <github organization>
```

## Output

the application creates a file in /tmp with all the results.

Sample of output:

```bash
quentin:/tmp/ $ cat /tmp/qoolbreeze_results.csv
org,repo_name,filename,line_number,value,secret_type,category
qoolbreeze,simple-github-org-scanner,test/test.txt,11|13|7|8,test_password,Hex High Entropy String,UNVERIFIED
qoolbreeze,simple-github-org-scanner,test/test2.txt,9,test_password2,Hex High Entropy String,UNVERIFIED
```

> :warning: the scanner is based on [detect-secrets](https://github.com/Yelp/detect-secrets) and can give some false positifs in the output 
