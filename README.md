# VirtualBox Dev Setup

These are my scripts for provisioning a new VirtualBox for PHP development. Many things are Taylor specific, such as the bash aliases and extensions for work related projects. However, feel free to fork and modify for your own usage.

## Instructions

Install Ubuntu 13.10 into new VirtualBox instance. Login to the box and select `Devices` -> `Insert Guest Additions CD image...` from the VirtualBox menu. Next, run the `setup` script to provision the box. After the box has been provisioned, you only need to setup your shared folder(s) and port forwarding. Everything else is ready to go. You may connect to the MySQL and Postgres instances via any database management program on your host, such as Sequel Pro or Navicat.

## Includes

- Apache
- PHP 5.5
- Composer
- PHPUnit
- Mailparse PHP Extension (For Snappy)
- Memcached
- Redis
- MySQL (Password: secret)
- Postgres (Password: secret)
- Beanstalkd Queue & Console (VirtualHost @ http://beansole.app)
- Node.js (With Grunt & Forever)
- Python Fabric & Hipchat Plugin
- SSH Key Generation
- Taylor's Serve Script
- Taylor's Bash Aliases