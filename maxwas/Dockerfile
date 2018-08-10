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

FROM maximo/ibmim

ARG url=http://images
ARG fp=7
ARG javafp=5.16

ENV TEMP /tmp
WORKDIR /tmp

RUN apt update && apt install -y tar bc net-tools netcat psmisc \
 && rm -rf /var/lib/apt/lists/*

RUN wget -q https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
    && mv wait-for-it.sh /usr/local/bin && chmod +x /usr/local/bin/wait-for-it.sh

RUN echo "root soft nofile 8192" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root hard nofile 8192" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root soft fsize -1" >> /etc/security/limits.d/99-maximo.conf
RUN echo "root hard fsize -1" >> /etc/security/limits.d/99-maximo.conf
RUN ulimit -f unlimited
RUN ulimit -n 8192
RUN echo "fs.file-max = 1232457" >> /etc/sysctl.d/99-maximo.conf

# Install IBM WebSphere Application Server traditional V9
ENV WASND_BASE_NAME WAS_ND_V9.0_MP_ML
ENV WASND_JAVA_BASE_NAME sdk.repo.8030.java8.linux
RUN wget -q ${url}/${WASND_BASE_NAME}.zip \
 && wget -q ${url}/${WASND_JAVA_BASE_NAME}.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.websphere.ND.v90 com.ibm.java.jdk.v8 \
   -repositories /tmp/${WASND_BASE_NAME}.zip,/tmp/${WASND_JAVA_BASE_NAME}.zip \
   -installationDirectory /opt/IBM/WebSphere/AppServer \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${WASND_BASE_NAME}* \
 && rm -rf ${WASND_JAVA_BASE_NAME}*

###### IBM WebSphere Application Server Network Deployment Fixpack #######

# Install IBM WebSphere Application Server traditional Fixpack
ENV WASFP_BASE_NAME 9.0.0-WS-WAS-FP00${fp}
RUN wget -q ${url}/${WASFP_BASE_NAME}.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.websphere.ND.v90 \
   -repositories /tmp/${WASFP_BASE_NAME}.zip \
   -installationDirectory /opt/IBM/WebSphere/AppServer \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${WASFP_BASE_NAME}*

# Install IBM Java SDK Fix pack
ENV JAVA_SDK_NAME ibm-java-sdk-8.0-${javafp}-linux-x64-installmgr
RUN wget -q ${url}/${JAVA_SDK_NAME}.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.java.jdk.v8 \
   -repositories /tmp/${JAVA_SDK_NAME}.zip \
   -installationDirectory /opt/IBM/WebSphere/AppServer \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${JAVA_SDK_NAME}*
