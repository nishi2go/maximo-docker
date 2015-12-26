# (C) Copyright IBM Corporation 2015.
# (C) Copyright Yasutaka Nishimura 2015.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM ibmcom/websphere-liberty:webProfile6

User root

RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense jaxws-2.2
RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense javaMail-1.5
RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense wasJmsClient-1.1
RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense jmsmdb-3.1
RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense wasjmsserver-1.0

# Install JRE 1.7
ENV JRE_VERSION 1.7.1_sr3fp10
RUN JRE_URL=$(wget -q -O - https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/jre/index.yml | sed -n '/'$JRE_VERSION'/{n;p}' | sed -n 's/\s*uri:\s//p' | tr -d '\r') \
    && wget -q $JRE_URL -U UA-IBM-WebSphere-Liberty-Docker -O /tmp/ibm-java.bin \
    && chmod +x /tmp/ibm-java.bin \
    && echo "INSTALLER_UI=silent" > /tmp/response.properties \
    && echo "USER_INSTALL_DIR=/opt/ibm/java17" >> /tmp/response.properties \
    && echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties \
    && /tmp/ibm-java.bin -i silent -f /tmp/response.properties \
    && rm /tmp/response.properties \
    && rm /tmp/ibm-java.bin
ENV JAVA_HOME /opt/ibm/java17
ENV PATH $JAVA_HOME/jre/bin:$PATH

COPY server.xml /config/
COPY jvm.options /config/

