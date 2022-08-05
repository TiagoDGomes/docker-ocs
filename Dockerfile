FROM alpine:3.8

RUN apk add --no-cache mysql apache2 apache2-utils php5-apache2 php5-xml

RUN mkdir -p /var/www/localhost/htdocs/ &&\
    cd /var/www/localhost/htdocs/  &&\
    wget --no-check-certificate https://pkp.sfu.ca/ocs/download/ocs-2.3.6.tar.gz &&\ 
    tar -xvf ocs-2.3.6.tar.gz &&\
    rm ocs-2.3.6.tar.gz &&\
    mv ocs-2.3.6 ocs
    
RUN mkdir -p /run/apache2 &&\
    echo '#!/bin/sh'     > /boot.sh  &&\
    echo 'exec 2>&1'     >> /boot.sh  &&\
    echo '/usr/sbin/httpd -DFOREGROUND & mysqld_safe &' >> /boot.sh  &&\
    echo 'sleep 360' >> /boot.sh  &&\
    rm -rf /var/www/localhost/htdocs/ocs/public &&\
    ln -s /data/public /var/www/localhost/htdocs/ocs/public &&\
    ln -s /var/www/localhost/htdocs/ocs/config.inc.php /data/config.inc.php  &&\
    chmod -R ugo+w /data &&\
    chmod -R ugo+w /var/www/localhost/htdocs/ocs/cache &&\
    chmod +x /boot.sh 
  
# Redirect output
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log
    
# Solve a security issue (https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html)
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow

EXPOSE 80

VOLUME /data

CMD [ "/boot.sh" ]
