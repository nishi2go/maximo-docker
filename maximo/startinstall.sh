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

# Watch and wait the DM process and database and web server
wait-for-it.sh ${APP_SERVER_HOST_NAME}:${APP_SERVER_PORT} -t 0 -q -- echo "Application Server is up"
wait-for-it.sh ${WEB_SERVER_HOST_NAME}:${WEB_SERVER_PORT} -t 0 -q -- echo "Web Server is up"
wait-for-it.sh ${DMGR_HOST_NAME}:${DMGR_PORT} -t 0 -q -- echo "Deployment Manager is up"
wait-for-it.sh ${DB_HOST_NAME}:${DB_PORT} -t 0 -q -- echo "Database is up"

DB_FQDN=`ping ${DB_HOST_NAME} -c 1 | head -n 2 | tail -n 1 | cut -f 4 -d ' ' | tr -d ':'`
WAS_DM_FQDN=`ping ${DMGR_HOST_NAME} -c 1 | head -n 2 | tail -n 1 | cut -f 4 -d ' ' | tr -d ':'`

if [ "${ENABLE_DEMO_DATA}" = "yes" ]
then
  DEMO_DATA="-deployDemoData"
fi

#copy skel files
CONFIG_FILE=/work/maximo-config.properties
if [ -f ${CONFIG_FILE} ]
then
  echo "Maximo has already configured."
  if [ "${UPDATE_APPS_ON_REBOOT}" = "yes" ]
  then
    /opt/IBM/SMP/ConfigTool/scripts/reconfigurePae.sh -action updateApplication \
        -updatedb -deploymaximoear -enableSkin "${SKIN}" -enableEnhancedNavigation
  fi

  if [ "${KEEP_RUNNING}" = "yes" ]
  then
    sleep inf &
    child=$!
    wait $child
  fi
  
  exit
fi

if [ "${DB_VENDOR}" = "Oracle" ]
then
  URL="jdbc:oracle:thin:@${DB_HOST_NAME}:${DB_PORT}/${MAXDB}"
fi

cat > ${CONFIG_FILE} <<EOF
MW.Operation=Configure
# Maximo Configuration Parameters
mxe.adminuserloginid=maxadmin
mxe.adminPasswd=${MAXADMIN_PASSWORD}
mxe.system.reguser=maxreg
mxe.system.regpassword=${MAXREG_PASSWORD}
mxe.int.dfltuser=mxintadm
maximo.int.dfltuserpassword=${MXINTADM_PASSWORD}
MADT.NewBaseLang=${BASE_LANG}
MADT.NewAddLangs=${ADD_LANGS}
mxe.adminEmail=${ADMIN_EMAIL_ADDRESS}
mail.smtp.host=${SMTP_SERVER_HOST_NAME}
mxe.db.user=maximo
mxe.db.password=${DB_MAXIMO_PASSWORD}
mxe.db.schemaowner=maximo
mxe.useAppServerSecurity=0

# Database Configuration Parameters
Database.Vendor=${DB_VENDOR}
Database.DB2.DatabaseName=${MAXDB}
Database.DB2.ServerHostName=${DB_FQDN}
Database.DB2.ServerPort=${DB_PORT}
Database.DB2.DataTablespaceName=${DB_TABLE_SPACE}
Database.DB2.TempTablespaceName=${DB_TEMP_SPACE}
Database.DB2.IndexTablespaceName=${DB_INDEX_SPACE}
Database.DB2.Vargraphic=true
Database.DB2.TextSearchEnabled=false

Database.UserSpecifiedJDBCURL=${URL}
Database.Oracle.ServerPort=${DB_PORT}
Database.Oracle.ServerHostName=${DB_FQDN}
Database.Oracle.InstanceName=${MAXDB}
Database.Oracle.DataTablespaceName=${DB_TABLE_SPACE}
Database.Oracle.TempTablespaceName=${DB_TEMP_SPACE}
Database.Oracle.IndexTablespaceName=${DB_INDEX_SPACE}

# WebSphere Configuration Parameters
ApplicationServer.Vendor=WebSphere
WAS.ND.AutomateConfig=true
WAS.DeploymentManagerHostName=${WAS_DM_FQDN}
WAS.NodeName=${WAS_NODE_NAME}

WAS.InstallLocation=/opt/IBM/WebSphere/AppServer
PLG.InstallLocation=/opt/IBM/WebSphere/Plugins
WCT.InstallLocation=/opt/IBM/WebSphere/Toolbox

IHS.AutomateConfig=true
IHS.HTTPPort=${WEB_SERVER_PORT}
IHS.InstallLocation=/opt/IBM/HTTPServer
IHS.WebserverName=${WEB_SERVER_NAME}
WAS.WebserverName=${WEB_SERVER_NAME}

WAS.ClusterAutomatedConfig=false
WAS.DeploymentManagerRemoteConfig=true
WAS.DeploymentManagerProfileName=${WAS_DM_PROFILE_NAME}
WAS.DeploymentManagerNodeName=${WAS_DM_NODE_NAME}
WAS.DeploymentManagerRemoteHostName=${WAS_DM_FQDN}
WAS.DeploymentManagerRemoteHostPort=${DMGR_PORT}
WAS.AdminUserName=${DMGR_ADMIN_USER}
WAS.AdminPassword=${DMGR_ADMIN_PASSWORD}
WAS.VirtualHost=maximo_host
EOF

# Run Configuration Tool
/opt/IBM/SMP/ConfigTool/scripts/reconfigurePae.sh -action deployConfiguration \
    -inputfile ${CONFIG_FILE} -automatej2eeconfig ${DEMO_DATA}

MAXIMO_DIR=/opt/IBM/SMP/maximo/applications/maximo
MAXIMO_PROPERTIES=${MAXIMO_DIR}/properties/maximo.properties
# Vendor specific configurations
if [ "${DB_VENDOR}" = "Oracle" ]
then
  mv ${MAXIMO_DIR}/lib/oraclethin.jar ${MAXIMO_DIR}/lib/oraclethin.jar.bak
  wget -q "http://search.maven.org/remotecontent?filepath=com/oracle/database/jdbc/ojdbc8/19.7.0.0/ojdbc8-19.7.0.0.jar" -O ${MAXIMO_DIR}/lib/oraclethin.jar
fi

if [ "${DB_VENDOR}" = "DB2" ]
then
  URL="jdbc:db2:\/\/${DB_HOST_NAME}:${DB_PORT}\/${MAXDB}"
  sed -i "s/^mxe.db.url=.*/mxe.db.url=${URL}/" "${MAXIMO_PROPERTIES}"
fi

INSTALL_PROPERTIES=/opt/IBM/SMP/etc/install.properties
sed -i "s/^Database.${DB_VENDOR}.ServerHostName=.*/Database.${DB_VENDOR}.ServerHostName=${DB_HOST_NAME}/" "${INSTALL_PROPERTIES}"

# Add 80 and 443 to maximo_host
/opt/IBM/SMP/ConfigTool/wasclient/ThinWsadmin.sh -lang jython \
    -username "${DMGR_ADMIN_USER}" -password "${DMGR_ADMIN_PASSWORD}" \
    -f /work/AddVirtualHosts.py ${WEB_SERVER_PORT}

# Enable application server auto restart
/opt/IBM/SMP/ConfigTool/wasclient/ThinWsadmin.sh -lang jython \
    -username "${DMGR_ADMIN_USER}" -password "${DMGR_ADMIN_PASSWORD}" \
    -f /work/SetAutoRestart.py

# Stop all application servers
# /opt/IBM/SMP/ConfigTool/wasclient/ThinWsadmin.sh -lang jython \
#    -username "${DMGR_ADMIN_USER}" -password "${DMGR_ADMIN_PASSWORD}" \
#    -f /work/StopAllServers.py

sleep 10

/opt/IBM/SMP/ConfigTool/scripts/reconfigurePae.sh -action updateApplication \
    -updatedb -deploymaximoear -enableSkin "${SKIN}" -enableEnhancedNavigation

# Start all application servers ... sometimes to fail to start servers duing updateApplicaton task
/opt/IBM/SMP/ConfigTool/wasclient/ThinWsadmin.sh -lang jython \
    -username "${DMGR_ADMIN_USER}" -password "${DMGR_ADMIN_PASSWORD}" \
    -f /work/StartAllServers.py

if [ "${KEEP_RUNNING}" = "yes" ]
then
  sleep inf &
  child=$!
  wait $child
fi
