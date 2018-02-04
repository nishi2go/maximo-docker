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

## Create WebSphere Deployment Manager profile
PROFILE_PATH=$WAS_HOME/profiles/$PROFILE_NAME
if [ ! -d "$PROFILE_PATH" ] ; then
    $WAS_HOME/bin/manageprofiles.sh \
      -create \
      -templatePath $WAS_HOME/profileTemplates/management \
      -hostName `hostname -f` \
      -profileName $PROFILE_NAME \
      -profilePath $PROFILE_PATH \
      -cellName $CELL_NAME \
      -nodeName $NODE_NAME \
      -enableAdminSecurity  "true" \
      -adminUserName "$DMGR_ADMIN_USER" \
      -adminPassword "$DMGR_ADMIN_PASSWORD"
fi

# Start DM
$WAS_HOME/profiles/$PROFILE_NAME/bin/startManager.sh

# Watch and wait the DM process
while :
do
    unset pid
    pid=`ps -ef | grep $PROFILE_NAME | grep -v grep | awk '{ print $2 }'`
    if [ "$pid" = "" ] ; then
        exit 0
    fi
    sleep 10
done
