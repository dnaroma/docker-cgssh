FROM ficusio/openresty:latest
RUN mkdir /var/www/challenges
VOLUME /var/www/challenges
EXPOSE 80 443
