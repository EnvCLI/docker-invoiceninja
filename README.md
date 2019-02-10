# Docker Image for Invoice Ninja

Docker Image for invoice ninja (https://www.invoiceninja.com/)

## Repository Features

- This image contains a nginx, php fpm and the cronjobs required to run invoiceninja in a single container.
- Automatically building the latest version from source (cronjob every 8 hours).
- All releases will be tagged.

## Directories

To make your data persistent, you have to mount the following directories:

- `/var/www/app/public/logo`
- `/var/www/app/storage`.

## Usage

To run it:

```
docker run -d \
  -e APP_ENV='production' \
  -e APP_DEBUG=0 \
  -e APP_URL='http://ninja.dev' \
  -e APP_KEY='SomeRandomStringSomeRandomString' \
  -e APP_CIPHER='AES-256-CBC' \
  -e DB_TYPE='mysql' \
  -e DB_STRICT='false' \
  -e DB_HOST='localhost' \
  -e DB_DATABASE='ninja' \
  -e DB_USERNAME='ninja' \
  -e DB_PASSWORD='ninja' \
  -p '80:80' \
  envcli/invoiceninja:latest
```

View all available tags [here][https://hub.docker.com/r/envcli/invoiceninja/tags].

## Configuration

A list of environment variables can be found [here](https://github.com/invoiceninja/invoiceninja/blob/master/.env.example)
