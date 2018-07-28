############################################################
# Dockerfile
############################################################

# Extends: OpenJDK 8 (Alpine)
FROM invoiceninja/invoiceninja:alpine-4.5.1

############################################################
# Environment Configuration
############################################################

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
	apk add --no-cache $PACKAGES

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
