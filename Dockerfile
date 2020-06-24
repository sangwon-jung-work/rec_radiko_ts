FROM ubuntu:16.04
MAINTAINER swjung89 <sangwon-jung-work@gmail.com>

RUN apt-get update -y && apt-get install -y software-properties-common python-software-properties build-essential libxml2-utils curl rtmpdump wget git zlib1g-dev tzdata openssl libssl-dev
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN mkdir /var/src
WORKDIR /var/src
RUN wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz && tar zxvf yasm-1.2.0.tar.gz && cd yasm-1.2.0 && ./configure && make && make install
RUN git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg && cd ffmpeg && ./configure --enable-openssl && make && make install

RUN echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf && ldconfig

ADD rec_radiko_ts.sh /usr/local/bin/rec_radiko_ts.sh
RUN chmod +x /usr/local/bin/rec_radiko_ts.sh
RUN mkdir /rec
WORKDIR /rec
ENTRYPOINT ["/usr/local/bin/rec_radiko_ts.sh"]
