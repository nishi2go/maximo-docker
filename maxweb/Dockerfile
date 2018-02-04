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
ARG fp=12

WORKDIR /tmp

# Install IBM HTTP Server 8.5.5 and WebSphere Plugin 8.5.5
ENV WASND_SUPPL_NAME WAS_V8.5.5_SUPPL
RUN mkdir ${WASND_SUPPL_NAME} \
 && wget -q ${url}/${WASND_SUPPL_NAME}_1_OF_3.zip \
 && unzip -qd ./${WASND_SUPPL_NAME} ${WASND_SUPPL_NAME}_1_OF_3.zip \
 && rm ${WASND_SUPPL_NAME}_1_OF_3.zip \
 && wget -q ${url}/${WASND_SUPPL_NAME}_2_OF_3.zip \
 && unzip -qd ./${WASND_SUPPL_NAME} ${WASND_SUPPL_NAME}_2_OF_3.zip \
 && rm ${WASND_SUPPL_NAME}_2_OF_3.zip \
  && wget -q ${url}/${WASND_SUPPL_NAME}_3_OF_3.zip \
 && unzip -qd ./${WASND_SUPPL_NAME} ${WASND_SUPPL_NAME}_3_OF_3.zip \
 && rm ${WASND_SUPPL_NAME}_3_OF_3.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.websphere.IHS.v85 \
   -repositories ${WASND_SUPPL_NAME}/repository.config \
   -properties user.ihs.httpPort=80 \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.websphere.PLG.v85 \
   -repositories ${WASND_SUPPL_NAME}/repository.config \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${WASND_SUPPL_NAME}*

# Install IBM HTTP Server 8.5.5 FP11 and WebSphere Plugin 8.5.5 FP11
ENV WASFP_SUPPL_NAME 8.5.5-WS-WASSupplements-FP0${fp}
RUN mkdir ${WASFP_SUPPL_NAME} \
 && wget -q ${url}/${WASFP_SUPPL_NAME}-part1.zip \
 && unzip -qd ./${WASFP_SUPPL_NAME} ${WASFP_SUPPL_NAME}-part1.zip \
 && rm ${WASFP_SUPPL_NAME}-part1.zip \
 && wget -q ${url}/${WASFP_SUPPL_NAME}-part2.zip \
 && unzip -qd ./${WASFP_SUPPL_NAME} ${WASFP_SUPPL_NAME}-part2.zip \
 && rm ${WASFP_SUPPL_NAME}-part2.zip \
 && wget -q ${url}/${WASFP_SUPPL_NAME}-part3.zip \
 && unzip -qd ./${WASFP_SUPPL_NAME} ${WASFP_SUPPL_NAME}-part3.zip \
 && rm ${WASFP_SUPPL_NAME}-part3.zip \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install  com.ibm.websphere.IHS.v85 \
   -repositories ${WASFP_SUPPL_NAME}/repository.config \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && /opt/IBM/InstallationManager/eclipse/tools/imcl \
   -acceptLicense install com.ibm.websphere.PLG.v85 \
   -repositories ${WASFP_SUPPL_NAME}/repository.config \
   -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false \
 && rm -rf ${WASFP_SUPPL_NAME}*

WORKDIR /opt

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
ENV WEB_SERVER_PORT 80

COPY startihs.sh /opt
COPY CreateWebServer.py /opt
RUN chmod +x /opt/startihs.sh

EXPOSE 80 443 34450 7272 9353 9900 8878 9201 9202 7062 2809 11004 9629

ENTRYPOINT ["/opt/startihs.sh"]
