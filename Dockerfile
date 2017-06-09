FROM ubuntu:latest
MAINTAINER "Chris Miller" <c.a.miller@wustl.edu>

############################
# java stuff for picard #
ENV JAVA_VERSION=8
# Install necessary packages including java 8 jre and clean up apt caches
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections

RUN apt-get update && apt-get --no-install-recommends install -y --force-yes \
    oracle-java${JAVA_VERSION}-installer && \ 
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ /var/cache/oracle-jdk${JAVA_VERSION}-installer 


################################
# biscuit #
ENV container docker
RUN apt-get update && apt-get install -y build-essential gcc-multilib apt-utils zlib1g-dev git wget libncurses5-dev libnss-sss

RUN cd / && \
    git clone https://github.com/zwdzwd/biscuit.git && \
    cd /biscuit && \
    pwd && \
    make && \
    cp /biscuit/bin/biscuit /usr/bin && \
    cd / && \
    wget "https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2" && \
    tar -jxvf samtools-1.3.1.tar.bz2 && \
    cd samtools-1.3.1 && \
    make && \
    cp samtools /usr/bin 

VOLUME [ "/data" ]


#how i run:
#docker run -ti -d --name=biscuit_docker -v /root/biscuit:/data biscuit

#connect to live instance
#docker exec -it biscuit_docker /bin/bash
