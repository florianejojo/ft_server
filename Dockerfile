FROM debian:buster

COPY /srcs/cmd.sh ./

RUN apt-get update && apt-get install -y nginx &&\
    apt-get install -y wget &&\
    apt-get install -y mariadb-server &&\
    apt-get install -y php-fpm php-mysql php-json php-mbstring php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip


#Configuring Nginx to Use the PHP Processor
RUN chown -R www-data:www-data /var/www/* && chmod -R 755 /var/www/*
RUN mkdir -p /var/www/mywebsite/phpmyadmin /var/www/mywebsite/wordpress
COPY /srcs/nginx.conf /etc/nginx/sites-available/mywebsite
RUN ln -s /etc/nginx/sites-available/mywebsite /etc/nginx/sites-enabled/

#SSL
RUN mkdir etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx-selfsigned.key -out /etc/nginx/ssl/nginx-selfsigned.crt -subj "/C=FR/ST=Lille/L=Paris/O=42 School/OU=flolefeb/CN=mywebsite"
#RUN echo "ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;\nssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;" > /etc/nginx/snippets/self-signed.conf


#mariaDB - 1 database, 1 person, 1 access
RUN service mysql start &&\
    mariadb -e "CREATE DATABASE wp_database;" &&\
    mariadb -e "GRANT ALL ON wp_database.* TO 'wp_user'@'localhost' IDENTIFIED BY 'wp_pass' WITH GRANT OPTION;" &&\
    mariadb -e "FLUSH PRIVILEGES;"

#Install wordpress
RUN wget https://wordpress.org/latest.tar.gz &&\
    tar -xvzf latest.tar.gz -C /var/www/mywebsite/ 
COPY /srcs/wordpress.conf /var/www/mywebsite/

#Install and configure PHPmyadmin

RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz &&\
    tar -zxvf phpMyAdmin-4.9.0.1-all-languages.tar.gz --strip-components 1 -C /var/www/mywebsite/phpmyadmin
COPY /srcs/config.inc.php /var/www/mywebsite/phpmyadmin

CMD bash cmd.sh

