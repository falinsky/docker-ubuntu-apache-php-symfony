Docker PHP+Apache2 image based on ubuntu 14.04
==============================================

Designed for running [Symfony](http://symfony.com/) applications in [Docker](https://www.docker.com/) container and editing code on the host machine.

How to use
-----------------------------------------------

`docker run -d --name my-great-app -v "$PWD":/unison -p 80:80 -p 443:443 falinsky/docker-ubuntu-apache-php-symfony:latest`


