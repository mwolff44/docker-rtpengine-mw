FROM debian:stretch

MAINTAINER Mathias WOLFF <mathias@celea.org>

# avoid httpredir errors
RUN sed -i 's/httpredir/deb/g' /etc/apt/sources.list

RUN rm -rf /var/lib/apt/lists/* && apt-get update &&   apt-get install --assume-yes gnupg wget git curl

RUN apt-get update && apt-get install -y \
       build-essential \
       dpkg-dev \
       debhelper \
       iptables-dev \
       netcat \
       libcurl4-openssl-dev \
       libglib2.0-dev \
       libhiredis-dev \
       libpcre3-dev \
       libssl-dev \
       markdown \
       libxmlrpc-core-c3-dev \
       nfs-common \
       dkms \
       default-libmysqlclient-dev \
       libmariadb-dev \
       libavcodec-dev \
       libavfilter-dev \
       libavformat-dev \
       libavresample-dev \
       libavutil-dev \
       libevent-dev \
       libjson-glib-dev \
       libpcap-dev \
       zlib1g-dev \
       unzip \
       module-assistant \
       libbencode-perl \
       libcrypt-rijndael-perl \
       libdigest-hmac-perl \
       libio-socket-inet6-perl \
       libsocket6-perl \
       gperf \
       libcrypt-openssl-rsa-perl \
       libdigest-crc-perl \
       libio-multiplex-perl \
       libnet-interface-perl \
       libspandsp-dev \
       libsystemd-dev
# \
#    && apt-get clean && rm -rf /var/lib/apt/lists

# Install bcg729
RUN curl https://codeload.github.com/BelledonneCommunications/bcg729/tar.gz/1.0.4 >bcg729_1.0.4.orig.tar.gz && tar zxf bcg729_1.0.4.orig.tar.gz
WORKDIR bcg729-1.0.4
RUN git clone https://github.com/ossobv/bcg729-deb.git debian && \
    dpkg-buildpackage -us -uc -sa && cd .. && \
    dpkg -i libbcg729-*.deb 
#&& \
   # dpkg -i libbcg729-0-dbg_1.0.4-0osso1+deb9_amd64.deb && \
   # dpkg -i libbcg729-dev_1.0.4-0osso1+deb9_amd64.deb

# rtpengine repo
RUN cd .. && git clone https://github.com/sipwise/rtpengine.git /rtpengine
WORKDIR /rtpengine

RUN dpkg-checkbuilddeps && \
    dpkg-buildpackage && \
    dpkg -i /*.deb&& \
    ( ( apt-get install -y linux-headers-$(uname -r) linux-image-$(uname -r) && \
        module-assistant update && \
        module-assistant auto-install ngcp-rtpengine-kernel-source ) || true )
##  && apt-get clean && rm -rf /var/lib/apt/*

# We need some environment variables to work please review and modify
ENV RUN_RTPENGINE=yes
ENV LISTEN_TCP=25060
ENV LISTEN_UDP=12222
ENV LISTEN_NG=22222
ENV LISTEN_CLI=9900
ENV TIMEOUT=60
ENV SILENT_TIMEOUT=3600
ENV PIDFILE=/var/run/ngcp-rtpengine-daemon.pid
ENV FORK=no
ENV TABLE=0
ENV PORT_MIN=16384
ENV PORT_MAX=16485
ENV LOG_LEVEL=7

# Get the startup script.  It's long and complicated
COPY run.sh /run.sh
RUN chmod 755 /run.sh

CMD /run.sh
