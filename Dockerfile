FROM phusion/baseimage:0.9.13
MAINTAINER Daniel Zwicker <email@daniel-zwicker.de>

ENV DEBIAN_FRONTEND noninteractive

######### Set locale to UTF-8 ###################
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN echo LANG=\"en_US.UTF-8\" > /etc/default/locale

######### upgrade system and install java certs ##
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install wget ca-certificates-java

# Install Java
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get install -y oracle-java7-installer
 

######### Install youtrack ###################
ENV YOUTRACK_VERSION 6.0.12102

RUN mkdir -p /usr/local/youtrack
RUN mkdir -p /var/lib/youtrack
RUN wget -nv http://download.jetbrains.com/charisma/youtrack-$YOUTRACK_VERSION.jar -O /usr/local/youtrack/youtrack-$YOUTRACK_VERSION.jar
RUN ln -s /usr/local/youtrack/youtrack-$YOUTRACK_VERSION.jar /usr/local/youtrack/youtrack.jar

ADD ./etc /etc

EXPOSE 8080

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD ["/sbin/my_init"]
