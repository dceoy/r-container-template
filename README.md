templr
======

R-based data analyzing template for command line

Docker image
------------

Build an image using docker-compose

```sh
$ docker-compose build
```

Usage
-----

Start a Docker container

```sh
$ docker-compose up
```

Print help messages

```sh
$ docker-compose run --rm templr --help
Run a data analysis worlkflow

Usage:
  main.R [--in=<dir>] [--out=<dir>] [--thread=<int>] [--seed=<int>] [--debug]

Options:
  -v, --version   Print version and exit
  -h, --help      Print help and exit
  --in=<dir>      Set an input directory [default: ./input]
  --out=<dir>     Set an output directory [default: ./output]
  --thread=<int>  Limit multithreading
  --seed=<int>    Set a random seed
  --debug         Run with debug logging
```
