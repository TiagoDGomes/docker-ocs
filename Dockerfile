FROM alpine:3.8

RUN apk add --no-cache mysql apache2 apache2-utils php5-apache2 php5-xml php5-mysql php5-ctype php5-ldap

RUN mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

RUN mkdir -p /var/www/localhost/htdocs/ &&\
    cd /var/www/localhost/htdocs/  &&\
    wget --no-check-certificate https://pkp.sfu.ca/ocs/download/ocs-2.3.6.tar.gz &&\ 
    tar -xvf ocs-2.3.6.tar.gz &&\
    rm ocs-2.3.6.tar.gz &&\
    mv ocs-2.3.6 ocs
    
RUN mkdir -p /run/apache2 &&\
    echo '#!/bin/sh'     > /boot.sh  &&\
    echo 'exec 2>&1'     >> /boot.sh  &&\
    echo 'rm /run/apache2/httpd.pid' >> /boot.sh  &&\
    echo 'rm /run/mysqld/mysqld.sock' >> /boot.sh  &&\
    echo '/usr/sbin/httpd -DFOREGROUND &' >> /boot.sh  &&\
    echo '/usr/bin/mysqld_safe --log-error=/dev/stderr' >> /boot.sh  &&\
    echo 'sleep 10' >> /boot.sh  &&\
    mkdir -p /var/www/localhost/htdocs/ocs/files &&\
    chmod ugo+w /var/www/localhost/htdocs/ocs/config.inc.php  &&\    
    chmod -R ugo+w /var/www/localhost/htdocs/ocs/public &&\
    chmod -R ugo+w /var/www/localhost/htdocs/ocs/files &&\
    chmod -R ugo+w /var/www/localhost/htdocs/ocs/cache &&\
    chmod +x /boot.sh 
  
# Redirect output
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log
    
# Solve a security issue (https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html)
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow

EXPOSE 80

VOLUME [ "/var/www/localhost/htdocs/ocs/public", "/var/www/localhost/htdocs/ocs/files", "/var/www/localhost/htdocs/ocs/cache", "/var/lib/mysql" ]

CMD [ "/boot.sh" ]
