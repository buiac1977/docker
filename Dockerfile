# Version 10/2017 

FROM debian:jessie
MAINTAINER Alin Sennewald <alinbuiac@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# install untils 
RUN apt-get update && apt-get upgrade -y --force-yes && apt-get install -y --force-yes --no-install-recommends apt-utils
RUN apt-get -y --force-yes install wget apt-transport-https

RUN apt-get -y --force-yes install \
unzip \
perl \
git \
apt-transport-https \
sudo etherwake \
dfu-programmer \
build-essential \
snmpd \
snmp \
vim \
telnet \
usbutils \
sqlite3 \
&& apt-get clean

# perl packages
RUN apt-get -y --force-yes install perl-base \
libdevice-serialport-perl \ 
libwww-perl \
libio-socket-ssl-perl \ 
libcgi-pm-perl \
libjson-perl \
sqlite3 \
libdbd-sqlite3-perl \ 
libtext-diff-perl \
libtimedate-perl \
&& apt-get clean

# install mqtt
RUN cpan install Net::MQTT:Simple

# install fhem
RUN wget -qO - https://debian.fhem.de/archive.key | apt-key add -
RUN echo "deb https://debian.fhem.de/nightly/ /" | tee -a /etc/apt/sources.list.d/fhem.list
RUN apt-get update
RUN apt-get -y --force-yes install supervisor fhem telnet
RUN mkdir -p /var/log/supervisor

# Timezone
RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure tzdata

# install tablet ui
RUN wget https://github.com/knowthelist/fhem-tablet-ui/archive/master.zip
RUN unzip master.zip && rm master.zip
RUN cp -r ./fhem-tablet-ui-master/www/tablet /opt/fhem/www/
RUN cp /opt/fhem/www/tablet/index-example.html /opt/fhem/www/tablet/index.html

# fhem cfg config
RUN echo 'define TABLETUI HTTPSRV ftui/ ./www/tablet/ Tablet-UI' >> /opt/fhem/fhem.cfg
RUN echo 'attr WEB JavaScripts codemirror/fhem_codemirror.js' >> /opt/fhem/fhem.cfg
RUN echo 'attr WEB editConfig 1' >> /opt/fhem/fhem.cfg
RUN echo 'attr WEB menuEntries Backup,/fhem?cmd=backup,Update,cmd=update,UpdateCheck,cmd=update+check,Restart,cmd=shutdown+restart' >> /opt/fhem/fhem.cfg

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/opt/fhem"]
EXPOSE 8083

CMD ["/usr/bin/supervisord"]
