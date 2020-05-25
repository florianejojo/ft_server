FROM debian:buster

RUN apt-get update && apt-get install -y nginx
RUN apt-get install -y mariadb-server
RUN apt-get install -y openssl

#Installing PHP for Processing
RUN apt-get -y install php-fpm php-mysql

#Configuring Nginx to Use the PHP Processor
RUN mkdir -p /var/www/my_domain
RUN chown -R www-data:www-data /var/www/my_domain && chmod -R 755 /var/www/my_domain
COPY /srcs/my_domain /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/my_domain /etc/nginx/sites-enabled/

#mariaDB - 1 database, 1 person, 1 access
RUN mkdir /var/www/my_domain/mariadb 
#COPY srcs/create_tables.sql /var/www/my_domain/mariadb
RUN service mysql start &&\
    #mariadb < /var/www/my_domain/mariadb/create_tables.sql && \
	mariadb -e "CREATE DATABASE database1 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" && \
    mariadb -e "GRANT ALL ON database1.* TO 'user1'@'localhost' IDENTIFIED BY 'pass1' WITH GRANT OPTION;" &&\
    mariadb -e "FLUSH PRIVILEGES;"

#ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj '/C=FR/ST=75017/L=Paris/O=42/CN=my_domain' 

#Install and configure PHPMYADMIN
RUN apt-get install -y php-json php-mbstring
RUN apt-get install -y wget
RUN mkdir /var/www/my_domain/phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz &&\
    tar -zxvf phpMyAdmin-4.9.0.1-all-languages.tar.gz --strip-components 1 -C /var/www/my_domain/phpmyadmin
COPY ./srcs/config.inc.php /var/www/my_domain/phpmyadmin

#install WP
RUN apt-get install -y php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip
RUN mkdir /var/www/my_domain/wordpress
RUN wget https://wordpress.org/latest.tar.gz && tar -zxvf latest.tar.gz --strip-components 1 -C /var/www/my_domain/wordpress
COPY ./srcs/wp-config.php /var/www/my_domain/wordpress/wp-config.php

COPY srcs/start_services.sh ./
CMD bash start_services.sh