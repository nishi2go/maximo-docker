#!/bin/bash
# © Copyright Yasutaka Nishimura 2017.
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
  $WAS_HOME/profiles/$PROFILE_NAME/bin/stopNode.sh \
    -username "$DMGR_ADMIN_USER" -password "$DMGR_ADMIN_PASSWORD"
}

# Wait until Deployment Manager and IHS port is opened
wait-for-it.sh $DB_HOST_NAME:$DB_PORT -t 0 -q -- echo "Database is up"

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
          -nodeName $NODE_NAME

    wait-for-it.sh $WEB_SERVER_HOST_NAME:$WEB_SERVER_PORT -t 0 -q -- echo "Web Server is up"
    wait-for-it.sh $DMGR_HOST_NAME:$DMGR_PORT -t 0 -q -- echo "Deployment Manager is up"
    until $WAS_HOME/profiles/$PROFILE_NAME/bin/addNode.sh $DMGR_HOST_NAME $DMGR_PORT -username "$DMGR_ADMIN_USER" -password "$DMGR_ADMIN_PASSWORD"
    do
        # Remove and create profile
        $WAS_HOME/bin/manageprofiles.sh \
          -delete \
          -profileName $PROFILE_NAME \

        rm -rf $PROFILE_PATH

        $WAS_HOME/bin/manageprofiles.sh \
          -create \
          -templatePath $WAS_HOME/profileTemplates/managed \
          -hostName `hostname -f` \
          -profileName $PROFILE_NAME \
          -profilePath $PROFILE_PATH \
          -cellName $CELL_NAME \
          -nodeName $NODE_NAME
    done
else
  $WAS_HOME/profiles/$PROFILE_NAME/bin/startNode.sh
fi

trap sigterm_handler SIGTERM

# Watch and wait the nodeagent process
while :
do
    unset pid
    pid=`ps -ef | grep $NODE_NAME | grep -v grep | awk '{ print $2 }'`
    if [ "$pid" = "" ] ; then
        exit 0
    fi
    sleep 10
done
