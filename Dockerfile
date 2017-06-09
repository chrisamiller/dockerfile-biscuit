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

############################
# sambamba # 
RUN apt-get update && apt-get install -y build-essential gcc-multilib apt-utils zlib1g-dev git wget

RUN cd /tmp/ && \
    wget https://github.com/ldc-developers/ldc/releases/download/v0.17.1/ldc2-0.17.1-linux-x86_64.tar.xz && \
    tar xJf ldc2-0.17.1-linux-x86_64.tar.xz
ENV PATH=/tmp/ldc2-0.17.1-linux-x86_64/bin/:$PATH
ENV LIBRARY_PATH=/tmp/ldc2-0.17.1-linux-x86_64/lib/

RUN cd /tmp/ && git clone --recursive https://github.com/lomereiter/sambamba.git

RUN cd /tmp/sambamba && git checkout tags/v0.6.4 && make sambamba-ldmd2-64 

RUN cp /tmp/sambamba/build/sambamba /usr/local/bin

RUN rm -rf /tmp/sambamba

ADD test.sh /
RUN chmod 775 /test.sh

RUN apt-get install -y libnss-sss

RUN apt-get remove --yes --purge build-essential gcc-multilib apt-utils zlib1g-dev git wget

RUN apt-get clean

################################
# biscuit #
ENV container docker
    apt-get install libncurses5-dev -y

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
