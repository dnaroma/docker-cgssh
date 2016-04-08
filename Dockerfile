FROM tenstartups/openresty:latest
RUN rm -rf /etc/nginx/nginx.conf
ADD /nginx/conf/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
EXPOSE 443
