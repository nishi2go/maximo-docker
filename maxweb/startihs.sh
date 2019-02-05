#!/bin/bash
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

function sigterm_handler {
  /opt/IBM/HTTPServer/bin/apachectl -k stop
  $WAS_HOME/profiles/$PROFILE_NAME/bin/stopNode.sh \
    -username "$DMGR_ADMIN_USER" -password "$DMGR_ADMIN_PASSWORD"
}

# Wait until Deployment Manager port is opened
wait-for-it.sh $DMGR_HOST_NAME:$DMGR_PORT -t 0 -q -- echo "Deployment Manager is up"

mkdir -p /opt/IBM/WebSphere/Plugins/logs/$WEB_SERVER_NAME

## Create WebSphere Application Server profile
PROFILE_PATH=$WAS_HOME/profiles/$PROFILE_NAME
if [ ! -d "$PROFILE_PATH" ] ; then
    $WAS_HOME/bin/manageprofiles.sh \
          -create \
          -templatePath $WAS_HOME/profileTemplates/managed \
          -hostName `hostname -f` \
          -profileName $PROFILE_NAME \
          -profilePath $PROFILE_PATH \
          -cellName $CELL_NAME \
          -nodeName $NODE_NAME \
          -dmgrHost $DMGR_HOST_NAME \
          -dmgrPort $DMGR_PORT \
          -dmgrAdminUserName "$DMGR_ADMIN_USER" \
          -dmgrAdminPassword "$DMGR_ADMIN_PASSWORD"

	$WAS_HOME/bin/wsadmin.sh -lang jython -username "$DMGR_ADMIN_USER" -password "$DMGR_ADMIN_PASSWORD" \
  	-f /work/CreateWebServer.py $NODE_NAME $WEB_SERVER_NAME $WEB_SERVER_PORT \
    	 /opt/IBM/HTTPServer /opt/IBM/WebSphere/Plugins

  	echo "LoadModule was_ap22_module /opt/IBM/WebSphere/Plugins/bin/64bits/mod_was_ap22_http.so" >> /opt/IBM/HTTPServer/conf/httpd.conf
    echo "WebSpherePluginConfig /opt/IBM/WebSphere/Plugins/config/$WEB_SERVER_NAME/plugin-cfg.xml" >> /opt/IBM/HTTPServer/conf/httpd.conf
else
  $WAS_HOME/profiles/$PROFILE_NAME/bin/startNode.sh
fi

/opt/IBM/HTTPServer/bin/apachectl -k start

trap sigterm_handler SIGTERM

# Watch and wait the nodeagent
until ncat localhost 8878 >/dev/null 2>&1; do
  sleep 10
done

while ncat localhost 8878 >/dev/null 2>&1; do
  sleep 10
done
