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

FROM maximo/maxwas

MAINTAINER Yasutaka Nishimura nishi2go@gmail.com

ARG url=http://images
ARG fp=10
ARG javafp=5.25
ARG httpport=80

WORKDIR /tmp

# Install IBM HTTP Server V9
ENV WASND_IHS_NAME was.repo.9000.ihs
ENV WASND_JAVA_NAME sdk.repo.8030.java8.linux
RUN wget -q ${url}/${WASND_IHS_NAME}.zip \
 && wget -q ${url}/${WASND_JAVA_NAME}.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl -acceptLicense \
   install com.ibm.websphere.IHS.v90 com.ibm.java.jdk.v8 \
   -repositories /tmp/${WASND_IHS_NAME}.zip,/tmp/${WASND_JAVA_NAME}.zip \
   -properties user.ihs.httpPort=${httpport} \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${WASND_IHS_NAME}* \
 && rm -rf ${WASND_JAVA_NAME}*

# Install WebSphere Plugin V9
ENV WASND_PLG_NAME was.repo.9000.plugins
RUN wget -q ${url}/${WASND_PLG_NAME}.zip \
 && wget -q ${url}/${WASND_JAVA_NAME}.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl -acceptLicense \
   install com.ibm.websphere.PLG.v90 com.ibm.java.jdk.v8 \
   -repositories /tmp/${WASND_PLG_NAME}.zip,/tmp/${WASND_JAVA_NAME}.zip \
   -installationDirectory /opt/IBM/WebSphere/Plugins \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${WASND_PLG_NAME}* \
 && rm -rf ${WASND_JAVA_NAME}*

# Install IBM HTTP Server and WebSphere Plugin V9 fix pack 7
ENV WASFP_IHS_NAME 9.0.0-WS-IHSPLG-FP0${fp}
RUN wget -q ${url}/${WASFP_IHS_NAME}.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.websphere.IHS.v90 com.ibm.websphere.PLG.v90 \
   -repositories ${WASFP_IHS_NAME}.zip \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${WASFP_IHS_NAME}*

# Install IBM Java SDK Fix pack
ENV JAVA_SDK_NAME ibm-java-sdk-8.0-${javafp}-linux-x64-installmgr
RUN wget -q ${url}/${JAVA_SDK_NAME}.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.java.jdk.v8 \
   -repositories /tmp/${JAVA_SDK_NAME}.zip \
   -installationDirectory /opt/IBM/HTTPServer \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
  && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.java.jdk.v8 \
   -repositories /tmp/${JAVA_SDK_NAME}.zip \
   -installationDirectory /opt/IBM/WebSphere/Plugins \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${JAVA_SDK_NAME}*

RUN mkdir /work
WORKDIR /work

RUN wget -q https://raw.githubusercontent.com/wsadminlib/wsadminlib/master/bin/wsadminlib.py

ENV WAS_HOME /opt/IBM/WebSphere/AppServer
ENV PROFILE_NAME ctgWebSrv01
ENV CELL_NAME ctgNodeWSCell01
ENV NODE_NAME ctgNodeWebSrv01
ENV DMGR_HOST_NAME maxdmgr
ENV DMGR_PORT 8879
ENV DMGR_ADMIN_USER wasadmin
ENV DMGR_ADMIN_PASSWORD wasadmin
ENV WEB_SERVER_NAME webserver1
ENV WEB_SERVER_PORT ${httpport}

COPY startihs.sh /work
COPY CreateWebServer.py /work
RUN chmod +x /work/startihs.sh

EXPOSE ${httpport} 34450 7272 9353 9900 8878 9201 9202 7062 2809 11004 9629

ENTRYPOINT ["/work/startihs.sh"]
