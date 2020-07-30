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

FROM ubuntu:18.04

MAINTAINER Yasutaka Nishimura <nishi2go@gmail.com>

ARG url=http://images
ARG updateim=no

ENV TEMP /tmp
WORKDIR /tmp

# Install required packages
RUN apt update && apt install -y wget unzip && rm -rf /var/lib/apt/lists/*

# Install IBM Installation Manager 1.8.8
ENV IM_IMAGE IED_V1.8.8_Wins_Linux_86.zip

RUN mkdir /Install_Mgr && wget -q $url/$IM_IMAGE \
 && unzip -q -d /Install_Mgr $IM_IMAGE \
 && rm $IM_IMAGE \
 && /Install_Mgr/EnterpriseDVD/Linux_x86_64/EnterpriseCD-Linux-x86_64/InstallationManager/installc -log /tmp/IM_Install_Unix.xml -acceptLicense \
 && rm -rf /Install_Mgr

## Update Installation Manager
RUN if [ "${updateim}" = "yes" ]; then /opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.cic.agent; fi
