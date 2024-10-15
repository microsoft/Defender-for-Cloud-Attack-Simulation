FROM mcr.microsoft.com/cbl-mariner/base/core:2.0
RUN tdnf -y update && tdnf install -y nginx-1.22.1 php-8.1.29 nmap-7.93 curl-8.8.0 && tdnf clean all
RUN mkdir -p /run/php-fpm
COPY src/ /var/www/html
COPY files/ /home/user
COPY cfg/nginx.conf /etc/nginx/nginx.conf
COPY cfg/web.conf /etc/php-fpm.d/web.conf
RUN mkdir /var/lib/nginx
RUN chown nginx:nginx /var/www/html
CMD ["sh", "-c", "php-fpm && nginx -g 'daemon off;'"]
