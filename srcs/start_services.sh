#!/bin/bash

echo "daemon off;" >> /etc/nginx/nginx.conf
service mysql start
service php7.3-fpm start
service nginx start
bash