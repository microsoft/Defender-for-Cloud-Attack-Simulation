FROM mcr.microsoft.com/azurelinux/base/core:3.0
RUN tdnf -y update \
    && tdnf install -y \
        nginx-1.30.6-1.azl3 \
        php-8.3.35-2.azl3 \
        nmap-7.95-5.azl3 curl-8.11.1-12.azl3 \
    && tdnf clean all
RUN mkdir -p /run/php-fpm
COPY src/ /var/www/html
COPY files/ /home/user
COPY cfg/nginx.conf /etc/nginx/nginx.conf
COPY cfg/web.conf /etc/php-fpm.d/web.conf
RUN mkdir -p /var/lib/nginx
RUN chown nginx:nginx /var/www/html
COPY /NOTICE /NOTICE
CMD ["sh", "-c", "php-fpm && nginx -g 'daemon off;'"]
