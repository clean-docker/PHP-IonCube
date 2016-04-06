FROM ubuntu:14.04

MAINTAINER Rafael Corrêa Gomes <rafaelcg_stz@hotmail.com>

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    software-properties-common \
    python-software-properties

RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:ondrej/php5-oldstable

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    php5 

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apache2 \
    apache2-utils \
    libapache2-mod-php5 \
    bzip2 \
    php5-cli \
    php5-curl \
    zip \
    unzip \
    vim \
    mysql-client-5.5 \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN requirements="libpng12-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg62-turbo libpng12-dev libfreetype6-dev libjpeg62-turbo-dev" \
    && apt-get update && apt-get install -y $requirements && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && requirementsToRemove="libpng12-dev libmcrypt-dev libcurl3-dev libpng12-dev libfreetype6-dev libjpeg62-turbo-dev" \
    && apt-get purge --auto-remove -y $requirementsToRemove

RUN usermod -u 1000 www-data
RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www/html

ADD http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.bz2 /tmp/
RUN tar xvjfC /tmp/ioncube_loaders_lin_x86-64.tar.bz2 /tmp/ \
    && rm /tmp/ioncube_loaders_lin_x86-64.tar.bz2 \
    && mkdir -p /usr/local/ioncube \
    && cp /tmp/ioncube/ioncube_loader_lin_5.5.so /usr/local/ioncube \
    && rm -rf /tmp/ioncube
COPY 00-ioncube.ini /etc/php5/apache2/conf.d/00-ioncube.ini
COPY 00-ioncube.ini /etc/php5/cli/conf.d/00-ioncube.ini

VOLUME ["/var/www/html"]

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
