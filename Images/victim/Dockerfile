FROM mcr.microsoft.com/cbl-mariner/base/core:2.0
RUN tdnf -y update && tdnf install -y nginx php php-fpm nmap curl && tdnf clean all
RUN mkdir -p /run/php-fpm
COPY src/ /var/www/html
COPY files/ /files
COPY cfg/nginx.conf /etc/nginx/nginx.conf
COPY cfg/web.conf /etc/php-fpm.d/web.conf
RUN mkdir /var/lib/nginx
ENV NAME=mdc-simulation
CMD ["sh", "-c", "php-fpm && nginx -g 'daemon off;'"]
