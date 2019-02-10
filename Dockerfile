############################################################
# Dockerfile
############################################################

# Extends: PHP FPM
FROM php:7.3-fpm-alpine

############################################################
# Environment Configuration
############################################################
ENV VERSION "4.5.9"
ENV PHANTOMJS phantomjs-2.1.1-linux-x86_64 \
	LOG errorlog \
	SELF_UPDATER_SOURCE '' \
	PHANTOMJS_BIN_PATH /usr/local/bin/phantomjs

############################################################
# Installation
############################################################

# Install packages. Notes:
#   * git: a git client to check out repositories
ENV PACKAGES="\
  git \
  nginx \
  supervisor \
"

RUN echo "Installing Packages ..." &&\
	# Update Package List
	apk add --update &&\
	# Package Install [no-cache, because the cache would be within the build - bloating up the file size]
	apk add --no-cache $PACKAGES &&\
	# System Requirements
	apk add --no-cache git gmp-dev freetype-dev libjpeg-turbo-dev coreutils chrpath fontconfig libpng-dev libzip-dev &&\
	docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ &&\
    docker-php-ext-configure gmp &&\
    docker-php-ext-install iconv mbstring pdo pdo_mysql zip gd gmp opcache &&\
    echo "php_admin_value[error_reporting] = E_ALL & ~E_NOTICE & ~E_WARNING & ~E_STRICT & ~E_DEPRECATED">>/usr/local/etc/php-fpm.d/www.conf &&\
    cd /usr/share &&\
    curl  -L https://github.com/Overbryd/docker-phantomjs-alpine/releases/download/2.11/phantomjs-alpine-x86_64.tar.bz2 | tar xj &&\
    ln -s /usr/share/phantomjs/phantomjs /usr/local/bin/phantomjs &&\
    # set recommended PHP.ini settings (see https://secure.php.net/manual/en/opcache.installation.php)
	{ \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini &&\
	# download and install invoiceninja
	curl -o ninja.zip -SL https://download.invoiceninja.com/ninja-v${VERSION}.zip &&\
	unzip ninja.zip -d /var/www/ &&\
    rm ninja.zip &&\
    mv /var/www/ninja /var/www/app &&\
    mv /var/www/app/storage /var/www/app/docker-backup-storage  &&\
    mv /var/www/app/public /var/www/app/docker-backup-public  &&\
    mkdir -p /var/www/app/public/logo /var/www/app/storage &&\
    touch /var/www/app/.env &&\
    chmod -R 755 /var/www/app/storage &&\
    rm -rf /var/www/app/docs /var/www/app/tests /var/www/ninja

# Build CleanUp
## Removes all packages that have been flagged as build dependencies
RUN echo "CleanUp ..." &&\
	rm -rf /var/cache/apk/*

# Copy files from rootfs to the container
ADD rootfs /

# Permissions
RUN echo "Setting permissions ..." &&\
	chmod +x /usr/local/bin/invoiceninja-cron.sh

############################################################
# Execution
############################################################
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
