# docker-lamp-centos6

LAMP stack engined by Docker

## stack list

- Centos 6
- Apache 2.2
- php 5.6
- xdebug
- MySQL 5.6

## build from Docker file

Locate your application source to www/, then build.

## docker command

```
docker run --cap-add=SYS_ADMIN -p 80:80 -d yutaf/lamp-centos6
```

## Work with Vagrant Docker provider

#### Requirements

* Vagrant  
<http://www.vagrantup.com/downloads.html>
* VirtualBox  
<https://www.virtualbox.org/wiki/Downloads>

#### More Useful With

* direnv  
[https://github.com/zimbatm/direnv](https://github.com/zimbatm/direnv)  

#### Usage

```
First of all, move to repository root,
And

(If installed direnv)
	Usage: vd [options] [command]

(If not installed)
	Usage: ./bin/vd [options] [command]

  Options:

    -v, --version        output program version
    -h, --help           output help information

  Commands:
	
	up                   up vagrant with docker provider
	ssh                  ssh into docker host vm
	destroy              destroy docker host & docker
	
```

#### Tips

If it gets not working, try

```
vagrant reload
```
