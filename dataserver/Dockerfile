# Use the official Docker Hub Ubuntu base image
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive 

# Update the base image
#add-apt-repository ppa:ondrej/php && \
RUN \
apt-get update && \
apt-get -y upgrade && \
apt-get -y dist-upgrade && \
apt-get -y install software-properties-common && \
apt-get update && \
apt-get -y install apache2 libapache2-mod-php8.3 composer mysql-client rinetd git\
 php8.3-dev php8.3-xml php8.3-mbstring php8.3-mysql php8.3-memcached php8.3-curl php8.3-redis php8.3-igbinary php8.3-memcached\
 libmemcached11 libmemcachedutil2 libmemcached-dev zlib1g-dev

# Setup PHP
RUN \
sed -i 's/memory_limit = 128M/memory_limit = 1G/g' /etc/php/8.3/apache2/php.ini && \
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/8.3/apache2/php.ini && \
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.3/apache2/php.ini && \
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.3/cli/php.ini && \
sed -i 's/display_errors = On/display_errors = Off/g' /etc/php/8.3/apache2/php.ini && \
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED/g' /etc/php/8.3/apache2/php.ini

# Setup Apache2, Enable the new virtualhost and Override gzip configuration
COPY ./config/apache2/zotero.conf /etc/apache2/sites-available/
COPY ./config/apache2/gzip.conf /etc/apache2/conf-available/
RUN \
a2enmod rewrite headers && \
a2dissite 000-default && \
a2ensite zotero && \
a2enconf gzip

# Install AWS client
RUN \
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install && \
rm awscliv2.zip

# Chown log directory
RUN chown 33:33 /var/log/apache2

WORKDIR /var/www/zotero

# Get the last version of the zotero code
RUN \
git clone --recursive https://github.com/zotero/dataserver.git . && \
git clone https://github.com/zendframework/zf1.git /zf1 && \
mv -f /zf1/library/Zend/* ./include/Zend && \
rm -r -f /zf1

# Install dependencies
RUN composer install

# copy files
COPY ./init/www.sql /var/www/zotero/misc/www.sql
COPY ./init/init-mysql.sh /var/www/zotero/misc/init-mysql.sh

# Set the entrypoint file
COPY ./entrypoint.sh /
RUN chmod +x /*.sh
ENTRYPOINT ["/entrypoint.sh"]
