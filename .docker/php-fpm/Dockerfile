#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

#
#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------
#
# Installing tools and PHP extentions using "apt", "docker-php", "pecl",
#

# Install "curl", "libmemcached-dev", "libpq-dev", "libjpeg-dev",
#         "libpng-dev", "libfreetype6-dev", "libssl-dev", "libmcrypt-dev",
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
        curl \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libwebp-dev \
        libxpm-dev \
        libmcrypt-dev \
        libonig-dev; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    # Install the PHP pdo_mysql extention
    docker-php-ext-install pdo_mysql; \
    # Install the PHP pdo_pgsql extention
    docker-php-ext-install pdo_pgsql; \
    # Install the PHP gd library
    docker-php-ext-configure gd \
        --prefix=/usr \
        --with-jpeg \
        --with-webp \
        --with-xpm \
        --with-freetype; \
    docker-php-ext-install gd; \
    php -r 'var_dump(gd_info());'

RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    apt-get install -yqq \
    apt-utils \
    gnupg2 \
    git \
    libzip-dev zip unzip && \
    if [ ${LARADOCK_PHP_VERSION} = "7.3" ] || [ ${LARADOCK_PHP_VERSION} = "7.4" ] || [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
    docker-php-ext-configure zip; \
    else \
    docker-php-ext-configure zip --with-libzip; \
    fi && \
    docker-php-ext-install zip && \
    php -m | grep -q 'zip'

###########################################################################
# LDAP:
###########################################################################
ARG INSTALL_LDAP=true
RUN if [ ${INSTALL_LDAP} = true ]; then \
    apt-get install -yqq libldap2-dev && \
    ARCH=$(arch)   && \
    docker-php-ext-configure ldap --with-libdir="lib/${ARCH}-linux-gnu/" && \
    docker-php-ext-install ldap \
;fi

###########################################################################
# MongoDB:
###########################################################################
ARG INSTALL_MONGO=true
RUN if [ ${INSTALL_MONGO} = true ]; then \
    # Install the mongodb extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install mongo; \
        docker-php-ext-enable mongo; \
        php -m | grep -oiE '^mongo$'; \
    else \
        if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && { [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ] || [ $(php -r "echo PHP_MINOR_VERSION;") = "1" ] ;}; then \
            pecl install mongodb-1.9.2; \
        else \
            pecl install mongodb; \
        fi; \
        docker-php-ext-enable mongodb; \
        php -m | grep -oiE '^mongodb$'; \
    fi; \
fi

###########################################################################
# Human Language and Character Encoding Support:
###########################################################################
ARG INSTALL_INTL=true
RUN if [ ${INSTALL_INTL} = true ]; then \
    # Install intl and requirements
    apt-get install -yqq zlib1g-dev libicu-dev g++ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl \
;fi

###########################################################################
# Mysqli Modifications:
###########################################################################
ARG INSTALL_MYSQLI=true
RUN if [ ${INSTALL_MYSQLI} = true ]; then \
    docker-php-ext-install mysqli \
;fi

###########################################################################
# PHP REDIS EXTENSION
###########################################################################
ARG INSTALL_PHPREDIS=true
RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
    # Install Php Redis Extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install -o -f redis-4.3.0; \
    else \
        pecl install -o -f redis; \
    fi \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis \
;fi

###########################################################################
# ImageMagick:
###########################################################################
USER root
ARG INSTALL_IMAGEMAGICK=true
ARG IMAGEMAGICK_VERSION=latest
ENV IMAGEMAGICK_VERSION ${IMAGEMAGICK_VERSION}
RUN if [ ${INSTALL_IMAGEMAGICK} = true ]; then \
    apt-get install -yqq libmagickwand-dev imagemagick && \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
        cd /tmp && \
        if [ ${IMAGEMAGICK_VERSION} = "latest" ]; then \
            git clone https://github.com/Imagick/imagick; \
        else \
            git clone --branch ${IMAGEMAGICK_VERSION} https://github.com/Imagick/imagick; \
        fi && \
        cd imagick && \
        phpize && \
        ./configure && \
        make && \
        make install && \
        rm -r /tmp/imagick; \
    else \
        pecl install imagick; \
    fi && \
    docker-php-ext-enable imagick; \
    php -m | grep -q 'imagick' \
;fi

###########################################################################
# PHP Memcached:
###########################################################################
ARG INSTALL_MEMCACHED=true
RUN if [ ${INSTALL_MEMCACHED} = true ]; then \
    # Install the php memcached extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        echo '' | pecl -q install memcached-2.2.0; \
    else \
        echo '' | pecl -q install memcached; \
    fi \
    && docker-php-ext-enable memcached \
;fi

###########################################################################
# XSL:
###########################################################################
ARG INSTALL_XSL=true
RUN if [ ${INSTALL_XSL} = true ]; then \
    # Install the xsl extension
    apt-get -y install libxslt-dev && \
    docker-php-ext-install xsl \
;fi

###########################################################################
# Composer:
###########################################################################
RUN curl https://getcomposer.org/installer > composer-setup.php \
    && php composer-setup.php \ 
    && mv composer.phar /usr/local/bin/composer \ 
    && rm composer-setup.php;

###########################################################################
# Clean up:
###########################################################################
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

WORKDIR /var/app
EXPOSE 9000
CMD ["php-fpm"]