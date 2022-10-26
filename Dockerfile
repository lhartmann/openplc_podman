FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/Recife /etc/localtime

# Install apt dependencies
RUN apt-get update \
&& apt-get -y install \
build-essential pkg-config bison flex autoconf automake libtool make git libssl-dev \
python2.7 python-wxgtk3.0 libwxbase3.0-0v5 libwxgtk3.0-gtk3-0v5 python-pip \
libssl-dev libxml2-dev libxslt1-dev python2.7-d \
curl unzip openssh-server \
&& apt-get clean \
&& apt-get autoclean \
&& apt-get autoremove \
&& rm -rf /var/lib/apt/* /var/cache/apt/*

# Install python dependencies
RUN pip2 install future zeroconf==0.19.1 numpy==1.16.5 matplotlib==2.0.2 lxml==4.6.2 pyro sslpsk pyserial

# Download OpenPLC Editor
WORKDIR /usr/local/
RUN curl -L "https://openplcproject.com/wp-content/uploads/files/OpenPLC%20Editor%20for%20Linux.zip" > /tmp/editor.zip \
&& unzip -d /usr/local /tmp/editor.zip "OpenPLC_Editor/*" \
&& rm -f /tmp/editor.zip

# Compile matiec
WORKDIR /usr/local/OpenPLC_Editor/matiec/
RUN autoreconf -i \
&& ./configure \
&& make -s \
&& cp ./iec2c ../editor/arduino/bin/

RUN echo -e "#! /bin/bash\n\
cd /usr/local/OpenPLC_Editor/\n\
exec python editor/Beremiz.py" >> /bin/beremiz
RUN chmod a+x /bin/beremiz

# Prepare openssh-server
RUN echo PermitRootLogin without-password >> /etc/ssh/sshd_server
RUN mkdir /run/sshd/
CMD /usr/sbin/sshd -D
