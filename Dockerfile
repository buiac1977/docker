# Version 1 10/2017 

FROM debian:jessie

MAINTAINER Alin Sennewald <alinbuiac@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && apt-get upgrade -y --force-yes && apt-get install -y --force-yes --no-install-recommends apt-utils
RUN apt-get -y --force-yes install wget apt-transport-https

RUN apt-get -y --force-yes install \
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

# Install perl packages
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

# sshd on port 2222 and allow root login / password = fhem!
RUN apt-get -y --force-yes install openssh-server && apt-get clean   \
 && sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config  \
 && sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config \
 && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
 && echo "root:fhem!" | chpasswd \
 && /bin/rm  /etc/ssh/ssh_host_*
# RUN dpkg-reconfigure openssh-server

RUN cpan install Net::MQTT:Simple

RUN wget -qO - https://debian.fhem.de/archive.key | apt-key add -
RUN echo "deb https://debian.fhem.de/nightly/ /" | tee -a /etc/apt/sources.list.d/fhem.list
RUN apt-get update
RUN apt-get -y --force-yes install supervisor fhem telnet
RUN mkdir -p /var/log/supervisor

RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure tzdata

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/opt/fhem"]
EXPOSE 8083 2222

CMD ["/usr/bin/supervisord"]
