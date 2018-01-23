FROM dzwicker/docker-ubuntu:latest
MAINTAINER email@daniel-zwicker.de

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN \
    mkdir -p /var/lib/youtrack && \
    groupadd --gid 2000 youtrack && \
    useradd --system -d /var/lib/youtrack --uid 2000 --gid youtrack youtrack && \
    chown -R youtrack:youtrack /var/lib/youtrack

######### Install hub ###################
COPY entry-point.sh /entry-point.sh

RUN \
    export YOUTRACK_VERSION=2017.4 && \
    export YOUTRACK_BUILD=38399 && \
    mkdir -p /usr/local && \
    mkdir -p /var/lib/youtrack && \
    cd /usr/local && \
    echo "$YOUTRACK_VERSION" > version.docker.image && \
    curl -L https://download-cf.jetbrains.com/charisma/youtrack-${YOUTRACK_VERSION}.${YOUTRACK_BUILD}.zip > youtrack.zip && \
    unzip youtrack.zip && \
    mv /usr/local/youtrack-${YOUTRACK_VERSION}.${YOUTRACK_BUILD} /usr/local/youtrack && \
    rm -f youtrack.zip && \
    rm -rf /usr/local/youtrack/internal/java/linux-x64/man && \
    rm -rf /usr/local/youtrack/internal/java/mac-x64 && \
    rm -rf /usr/local/youtrack/internal/java/windows-amd64 && \
    chown -R youtrack:youtrack /usr/local/youtrack && \
    chmod -R u+rwxX /usr/local/youtrack/internal/java/linux-x64

USER youtrack
ENV HOME=/var/lib/youtrack
EXPOSE 8080
ENTRYPOINT ["/entry-point.sh"]
CMD ["run"]
