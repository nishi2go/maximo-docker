# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM ubuntu:16.04

MAINTAINER Yasutaka Nishimura nishi2go@gmail.com

ARG url=http://images

ARG ver=11.1
ARG fp=3fp3

## Install required software
RUN dpkg --add-architecture i386
RUN apt update -y && apt install -y wget unzip bsdtar netcat file libx32stdc++6 libpam0g:i386 binutils libaio1 libnuma1 \
    && rm -rf /var/lib/apt/lists/*

## Set kernel params
RUN echo "root soft nofile 8192" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root hard nofile 8192" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root soft fsize -1" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root hard fsize -1" >> /etc/security/limits.d/99-maximo.conf
RUN ulimit -f unlimited
RUN ulimit -n 8192

# Install IBM DB2 V10.5
ENV DB2_IMAGE DB2_AWSE_REST_Svr_${ver}_Lnx_86-64.tar.gz

RUN mkdir /work
WORKDIR /work

ENV MAXDB_DATADIR /home/ctginst1/ctginst1

ENV VARDB2_DATADIR /var/db2
VOLUME $VARDB2_DATADIR

ENV CTGINST1_PASSWORD ctginst1
ENV CTGFENC1_PASSWORD ctginst1
ENV DASUSR1_PASSWORD ctginst1
ENV MAXIMO_PASSWORD maximo

RUN groupadd ctggrp1
RUN groupadd ctgfgrp1
RUN groupadd dasadm1
RUN groupadd maximo
RUN useradd -g ctggrp1 -m -d /home/ctginst1 ctginst1
RUN echo "ctginst1:$CTGINST1_PASSWORD" | chpasswd
RUN useradd -g ctgfgrp1 -m -d /home/ctgfenc1 ctgfenc1
RUN echo "ctgfenc1:$CTGFENC1_PASSWORD" | chpasswd
RUN useradd -g dasadm1 -m -d /home/dasusr1 dasusr1
RUN echo "dasusr1:$DASUSR1_PASSWORD" | chpasswd
RUN useradd -g maximo -m -d /home/maximo maximo
RUN echo "maximo:$MAXIMO_PASSWORD" | chpasswd

VOLUME $MAXDB_DATADIR

# Install DB2 V11.1
COPY db2awse.rsp /work
RUN wget -q $url/$DB2_IMAGE \
  && bsdtar -zxpf $DB2_IMAGE \
  && ./server_awse_o/db2setup -r ./db2awse.rsp \
  && /opt/ibm/db2/V11.1/adm/db2licm -a ./server_awse_o/db2/license/db2awse_o.lic \
  && /opt/ibm/db2/V11.1/adm/db2licm -l \
  && rm -rf *

RUN /opt/ibm/db2/V${ver}/bin/db2fmcu -d

# Install DB2 Fixpack
ENV DB2_FP_IMAGE v${ver}.${fp}_linuxx64_server_t.tar.gz
RUN wget -q $url/$DB2_FP_IMAGE \
  && bsdtar -zxpf $DB2_FP_IMAGE \
  && cd server_t \
  && ./installFixPack -n -b /opt/ibm/db2/V${ver} \
   -f NOTSAMP -f update -f nobackup \
  && cd .. \
  && rm -rf *

RUN /opt/ibm/db2/V${ver}/instance/dascrt -u dasusr1

COPY db2fmcd.service /etc/systemd/system/db2fmcd.service
RUN chmod 644 /etc/systemd/system/db2fmcd.service
RUN systemctl enable db2fmcd

ENV MAXDB MAXDB76

COPY startdb2.sh /opt
RUN chmod +x /opt/startdb2.sh
ENTRYPOINT ["/opt/startdb2.sh"]
