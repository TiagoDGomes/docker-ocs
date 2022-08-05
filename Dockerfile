
FROM alpine:3.8

RUN apk add --no-cache mysql apache2 apache2-utils php5-apache2

RUN mkdir /opt &&\
    cd /opt  &&\
    wget https://github.com/pkp/ocs/archive/refs/tags/ocs-2_3_6-0.zip &&\ 
    unzip ocs-2_3_6-0.zip -d ./ &&\
    rm ocs-2_3_6-0.zip &&\
    mv ocs-ocs-2_3_6-0 ocs &&\
    mkdir -p /var/www/html &&\
    mkdir -p /run/apache2 &&\
    ln -s /opt/ocs /var/www/html/ocs &&\
    echo '#!/bin/sh'     > /boot.sh  &&\
    echo 'exec 2>&1'     >> /boot.sh  &&\
    echo '/usr/sbin/httpd -DFOREGROUND & ' >> /boot.sh  &&\
    echo 'sleep 360' >> /boot.sh  &&\
    chmod +x /boot.sh 
  
# Redirect output
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log
    
# Solve a security issue (https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html)
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow

EXPOSE 80

CMD [ "/boot.sh" ]
