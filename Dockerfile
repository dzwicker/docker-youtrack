FROM ubuntu:14.04
MAINTAINER daniel.zwicker@in2experience.com

# Set environment variables.
ENV HOME="/root" DEBIAN_FRONTEND=noninteractive

######### Set locale to UTF-8 ###################
RUN \
    locale-gen en_US.UTF-8 && \
    echo LANG=\"en_US.UTF-8\" > /etc/default/locale && \
    echo "Europe/Berlin" > /etc/timezone

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN \
    groupadd --gid 2000 youtrack && \
    useradd --system --uid 2000 --gid youtrack youtrack

######### upgrade system and install java certs ##
RUN \
    sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y wget software-properties-common && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java8-installer ca-certificates-java && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variables.
# Define commonly used JAVA_HOME variable
ENV JAVA_HOME="/usr/lib/jvm/java-8-oracle"

######### Install youtrack ###################
ADD ./etc /etc
ADD youtrack.sh /usr/local/youtrack.sh

RUN \
    export YOUTRACK_VERSION=6.5.16807 && \
    mkdir -p /usr/local/youtrack && \
    mkdir -p /var/lib/youtrack && \
    wget -nv https://download.jetbrains.com/charisma/youtrack-$YOUTRACK_VERSION.jar -O /usr/local/youtrack/youtrack-$YOUTRACK_VERSION.jar && \
    ln -s /usr/local/youtrack/youtrack-$YOUTRACK_VERSION.jar /usr/local/youtrack/youtrack.jar && \
    chown -R youtrack:youtrack /usr/local/youtrack && \
    chown -R youtrack:youtrack /var/lib/youtrack

USER youtrack
EXPOSE 8080
CMD ["/usr/local/youtrack.sh"]
