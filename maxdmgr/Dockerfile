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

ENV WAS_HOME /opt/IBM/WebSphere/AppServer
ENV PROFILE_NAME ctgDmgr01
ENV CELL_NAME ctgCell01
ENV NODE_NAME ctgCellManager01
ENV DMGR_ADMIN_USER wasadmin
ENV DMGR_ADMIN_PASSWORD wasadmin

COPY startdm.sh /opt
RUN chmod +x /opt/startdm.sh

EXPOSE 40541 11006 9632 9060 9352 9420 9100 7277 8879 9809 9043 7060 9402 9403

ENTRYPOINT ["/opt/startdm.sh"]
