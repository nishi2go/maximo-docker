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

MAINTAINER Yasutaka Nishimura <nishi2go@gmail.com>

ARG fp=7

ARG url=http://images

ENV TEMP /tmp
WORKDIR /tmp

RUN yum update -y && yum install -y wget unzip nc which && yum clean all

# Install IBM Installation Manager 1.8
ENV IM_IMAGE agent.installer.linux.gtk.x86_64_1.8.0.20140902_1503.zip

RUN mkdir /Install_Mgr && wget -q $url/$IM_IMAGE \
 && unzip -q -d /Install_Mgr $IM_IMAGE \
 && rm $IM_IMAGE \
 && /Install_Mgr/installc -log /tmp/IM_Install_Unix.xml -acceptLicense \
 && rm -rf /Install_Mgr

## Update Installation Manager
RUN /opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.cic.agent

## Install Maximo middleware and installer
RUN mkdir /Launchpad
WORKDIR /Launchpad

ENV BYPASS_PRS=True

## Install Maximo V7.6
ENV MAM_IMAGE MAM_7.6.0.0_LINUX64.tar.gz
RUN wget -q $url/$MAM_IMAGE && tar zxpf $MAM_IMAGE \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
 -input /Launchpad/SilentResponseFiles/Installer/Unix/ResponseFile_MAM_Install_Unix.xml \
 -acceptLicense -log /tmp/MAM_Install_Unix.xml \
 && rm $MAM_IMAGE

## Install Maximo V7.6.0.7 feature packs
RUN mkdir /work
WORKDIR /work
ENV MAM_FP_IMAGE MAMMTFP760${fp}IMRepo.zip

RUN wget -q $url/$MAM_FP_IMAGE && sleep 30 \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl install \
 com.ibm.tivoli.tpae.base.mam.main -repositories /work/$MAM_FP_IMAGE \
 -installationDirectory /opt/IBM/SMP -log /tmp/FP_Install_Unix.xml -acceptLicense \
 && rm $MAM_FP_IMAGE

ENV MAXADMIN_PASSWORD maxadmin
ENV MAXREG_PASSWORD maxreg
ENV MXINTADM_PASSWORD mxintadm
ENV BASE_LANG en
ENV ADMIN_EMAIL_ADDRESS root@localhost
ENV SMTP_SERVER_HOST_NAME localhost
ENV MAXDB MAXDB76
ENV DB_HOST_NAME maxdb
ENV DB_PORT 50005
ENV DB_MAXIMO_PASSWORD maximo
ENV DMGR_ADMIN_USER wasadmin
ENV DMGR_ADMIN_PASSWORD wasadmin
ENV DMGR_HOST_NAME maxdmgr
ENV DMGR_PORT 8879
ENV WAS_DM_PROFILE_NAME ctgDmgr01
ENV WAS_DM_NODE_NAME ctgCellManager01
ENV WAS_NODE_NAME ctgNode01
ENV WEB_SERVER_NAME webserver1
ENV WEB_SERVER_HOST_NAME maxweb
ENV WEB_SERVER_PORT 80
ENV APP_SERVER_HOST_NAME maxapps
ENV APP_SERVER_PORT 8878

RUN wget -q https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
    && mv wait-for-it.sh /usr/local/bin && chmod +x /usr/local/bin/wait-for-it.sh

RUN wget -q https://raw.githubusercontent.com/wsadminlib/wsadminlib/master/bin/wsadminlib.py \
    && mv wsadminlib.py /opt

COPY StopAllServers.py /opt
COPY StartAllServers.py /opt
COPY AddVirtualHosts.py /opt
COPY SetAutoRestart.py /opt

COPY startinstall.sh /work
RUN chmod +x startinstall.sh
ENTRYPOINT ["/work/startinstall.sh"]
