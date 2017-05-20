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
FROM centos:7

MAINTAINER Yasutaka Nishimura nishi2go@gmail.com

ARG url=http://images

ARG fp=7

## Install required software
RUN yum update -y && yum install -y wget unzip tar nc bc net-tools bind-utils \
    passwd pam pam.i686 ncurses-libs.i686 file libaio compat-libstdc++-33 compat-libstdc++-33.i686 && yum clean all

## Set kernel params
RUN echo "root soft nofile 8192" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root hard nofile 8192" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root soft fsize -1" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root hard fsize -1" >> /etc/security/limits.d/99-maximo.conf
RUN ulimit -f unlimited
RUN ulimit -n 8192

# Install IBM DB2 V10.5
ENV DB2_IMAGE DB2_Svr_V10.5_Linux_x86-64.tar.gz

RUN mkdir /work
WORKDIR /work

ENV MAXDB_DATADIR /home/ctginst1/
VOLUME $MAXDB_DATADIR

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

# Install DB2 V10.5
COPY db2ese.rsp /work
RUN wget -q $url/$DB2_IMAGE \
  && tar -zxpf $DB2_IMAGE \
  && ./server/db2setup -r ./db2ese.rsp \
  && rm -rf *

# Install DB2 Fixpack
ENV DB2_FP_IMAGE v10.5fp${fp}_linuxx64_server_t.tar.gz
RUN wget -q $url/$DB2_FP_IMAGE \
  && tar -zxpf $DB2_FP_IMAGE \
  && cd server_t \
  && ./installFixPack -b /opt/ibm/db2/V10.5 -f update \
  && cd .. \
  && rm -rf *

ENV DB2_LIC_FILE DB2_ESE_Restricted_QS_Act_V10.5.zip
RUN wget -q $url/$DB2_LIC_FILE \
 && unzip -q $DB2_LIC_FILE \
 && /opt/ibm/db2/V10.5/adm/db2licm -a ese_o/db2/license/db2ese_o.lic \
 && /opt/ibm/db2/V10.5/adm/db2licm -l \
 && rm -rf *

ENV MAXDB MAXDB76

COPY startdb2.sh /opt
RUN chmod +x /opt/startdb2.sh
ENTRYPOINT ["/opt/startdb2.sh"]
