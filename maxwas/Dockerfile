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

ARG url=http://images
ARG fp=12
ARG javafp=7.1.4.5

ENV TEMP /tmp
WORKDIR /tmp

RUN yum update -y && yum install -y wget ksh unzip tar bc net-tools bind-utils nc \
 pam.i686 psmisc compat-libstdc++-33 compat-libstdc++-33.i686 which && yum clean all

RUN wget -q https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
    && mv wait-for-it.sh /usr/local/bin && chmod +x /usr/local/bin/wait-for-it.sh

RUN echo "root soft nofile 8192" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root hard nofile 8192" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root soft fsize -1" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root hard fsize -1" >> /etc/security/limits.d/99-maximo.conf
RUN ulimit -f unlimited
RUN ulimit -n 8192
RUN echo "fs.file-max = 1232457" >> /etc/sysctl.d/99-maximo.conf

# Install IBM Installation Manager 1.8
ENV IM_IMAGE agent.installer.linux.gtk.x86_64_1.8.0.20140902_1503.zip

RUN mkdir /Install_Mgr && wget -q $url/$IM_IMAGE \
 && unzip -q -d /Install_Mgr $IM_IMAGE \
 && rm $IM_IMAGE \
 && /Install_Mgr/installc -log /tmp/IM_Install_Unix.xml -acceptLicense \
 && rm -rf /Install_Mgr

# Install IBM WebSphere Application Server ND v855
ENV WASND_BASE_NAME WASND_v8.5.5
RUN mkdir ${WASND_BASE_NAME} \
 && wget -q ${url}/${WASND_BASE_NAME}_1of3.zip \
 && unzip -qd ./${WASND_BASE_NAME} ${WASND_BASE_NAME}_1of3.zip \
 && rm ${WASND_BASE_NAME}_1of3.zip \
 && wget -q ${url}/${WASND_BASE_NAME}_2of3.zip \
 && unzip -qd ./${WASND_BASE_NAME} ${WASND_BASE_NAME}_2of3.zip \
 && rm ${WASND_BASE_NAME}_2of3.zip \
 && wget -q ${url}/${WASND_BASE_NAME}_3of3.zip \
 && unzip -qd ./${WASND_BASE_NAME} ${WASND_BASE_NAME}_3of3.zip \
 && rm ${WASND_BASE_NAME}_3of3.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.websphere.ND.v85 \
   -repositories /tmp/${WASND_BASE_NAME}/repository.config \
   -installationDirectory /opt/IBM/WebSphere/AppServer \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${WASND_BASE_NAME}*

###### IBM WebSphere Application Server Network Deployment Fixpack #######

# Install IBM WebSphere Application Server ND FP v85511
ENV WASFP_BASE_NAME 8.5.5-WS-WAS-FP0${fp}
RUN mkdir ${WASFP_BASE_NAME} \
 && wget -q ${url}/${WASFP_BASE_NAME}-part1.zip \
 && unzip -qd ./${WASFP_BASE_NAME} ${WASFP_BASE_NAME}-part1.zip \
 && rm ${WASFP_BASE_NAME}-part1.zip \
 && wget -q ${url}/${WASFP_BASE_NAME}-part2.zip \
 && unzip -qd ./${WASFP_BASE_NAME} ${WASFP_BASE_NAME}-part2.zip \
 && rm ${WASFP_BASE_NAME}-part2.zip \
 && wget -q ${url}/${WASFP_BASE_NAME}-part3.zip \
 && unzip -qd ./${WASFP_BASE_NAME} ${WASFP_BASE_NAME}-part3.zip \
 && rm ${WASFP_BASE_NAME}-part3.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.websphere.ND.v85 \
   -repositories /tmp/${WASFP_BASE_NAME}/repository.config \
   -installationDirectory /opt/IBM/WebSphere/AppServer \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${WASFP_BASE_NAME}*

# Install IBM Java SDK 7.1
ENV JAVA_SDK_NAME ${javafp}-WS-IBMWASJAVA-Linux
RUN mkdir ${JAVA_SDK_NAME} \
 && wget -q ${url}/${JAVA_SDK_NAME}.zip \
 && unzip -qd ./${JAVA_SDK_NAME} ${JAVA_SDK_NAME}.zip \
 && rm ${JAVA_SDK_NAME}.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.websphere.IBMJAVA.v71 \
   -repositories /tmp/${JAVA_SDK_NAME}/repository.config \
   -installationDirectory /opt/IBM/WebSphere/AppServer \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${JAVA_SDK_NAME}*

ENV PATH /opt/IBM/WebSphere/AppServer/bin:$PATH
RUN managesdk.sh -setCommandDefault -sdkname 1.7.1_64 \
 && managesdk.sh -setNewProfileDefault -sdkname 1.7.1_64
