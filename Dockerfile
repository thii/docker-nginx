FROM ubuntu:trusty

# Install packages
RUN echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" > /etc/apt/sources.list.d/nginx-stable-trusty.list
RUN echo "deb-src http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list.d/nginx-stable-trusty.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C

ENV NGINX_VERSION 1.8.1-1+trusty0

RUN apt-get update
RUN apt-get -y upgrade

# Install nginx
RUN apt-get install -y ca-certificates nginx=${NGINX_VERSION}

# PHP, memcached...
RUN \
  apt-get install -y \
  supervisor \
  curl \
  wget \
  tar \
  memcached \
  php5-fpm \
  php5-mysql \
  php5-mcrypt \
  php5-gd \
  php5-memcached \
  php5-memcache \
  php5-curl
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Change Timezone
RUN echo "Asia/Tokyo" | tee /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Create required directories
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/run/php5-fpm

# Add configuration files
ADD conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN rm -f /etc/nginx/sites-available/default
ADD conf.d/nginx/sites-available/no-default /etc/nginx/sites-available/no-default

# Delete the default configuration and copy the new one
RUN rm -v /etc/nginx/nginx.conf
ADD conf.d/nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
