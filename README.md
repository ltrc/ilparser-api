# ilparser-api
An API for Parsing Indic Languages

Installing Dependencies (Debian Derivatives):
```bash
$ sudo apt-get install gcc git libgdbm-dev libglib2.0-dev make python-numpy python-pydot python-urllib3
```

Installing Dependencies (Redhat Derivatives):
```bash
$ sudo yum install git gcc gdbm-devel glib2-devel make numpy pydot python-urllib3
```

To setup the repo after installing dependencies, do:
```bash
$ ./setup.sh
```

To run the api server:
```
$ perl api.pl prefork
```
