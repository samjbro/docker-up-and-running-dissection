FROM node:0.10

MAINTAINER Sam Broughton <sam@example.com>

LABEL "rating"="Five Stars" "class"="First Class"

USER root

ENV AP /data/app

ENV SCPATH /etc/supervisord/conf.d

RUN apt-get -y update

# The daemons
RUN apt-get -y install supervisor
RUN mkdir -p /var/log/supervisor

# Supervisor Configuration
ADD ./supervisord/conf.d/* $SCPATH/

# Application Code
ADD *.js* $AP/

WORKDIR $AP

RUN npm install

CMD ["supervisord", "-n"]