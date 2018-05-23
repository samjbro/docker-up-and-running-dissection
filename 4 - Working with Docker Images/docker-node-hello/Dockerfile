FROM centos:centos6

# Enable EPEL for Node.js
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

# Install Node.js and npm
RUN yum update -y && yum install -y -q npm

ADD . /src

RUN cd /src; npm config set strict-ssl false && npm install

EXPOSE 8080

CMD ["node", "/src/index.js"]