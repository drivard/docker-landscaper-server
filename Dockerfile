FROM ubuntu:18.04
MAINTAINER oliver@cloudsurge.co.uk

ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get install -y software-properties-common

#Add repository that contains the landscape server
RUN apt-get update
RUN apt-get install -fy gnupg2
RUN echo 'deb http://ppa.launchpad.net/landscape/19.10/ubuntu bionic main' > /etc/apt/sources.list.d/landscape-ubuntu-19_10-bionic.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6E85A86E4652B4E6
RUN apt-get update
RUN apt-get -fy dist-upgrade 

RUN apt-get -fy install supervisor
RUN apt-get -fy install apache2
RUN apt-get -fy install landscape-server

RUN for module in rewrite proxy_http ssl headers expires; do a2enmod $module; done
RUN a2dissite 000-default

COPY assets/landscape-service.conf /etc/landscape/service.conf
COPY assets/apache-landscape.conf /etc/apache2/sites-available/landscape.conf

COPY assets/certs/landscape_server.key /etc/ssl/private/
COPY assets/certs/landscape_server.pem /etc/ssl/certs/
COPY assets/certs/landscape_server_ca.crt /etc/ssl/certs/

RUN a2ensite landscape.conf

COPY assets/entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]
