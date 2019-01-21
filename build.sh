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

IMAGE_DIR=$1
CHECK_DIR=$1
PACKAGE_LIST=packages.list
MAXIMO_VER="${MAXIMO_VER:-7.6.1}"
IM_VER="${IM_VER:-1.8.8}"
WAS_VER="${WAS_VER:-9.0.0.7}"
DB2_VER="${DB2_VER:-11.1.3}"

while [[ $# -gt 0 ]]; do
  key="$1"
    case "$key" in
      -c | --check )
        CHECK=1
        ;;
      -C | --deepcheck )
        CHECK=1
        DEEP_CHECK=1
        ;;
      -d | --check-dir )
        shift
        CHECK_DIR="$1"
        ;;
      -h | --help )
        SHOW_HELP=1
        ;;
      -g )
        GEN_PKG_LIST=1
        ;;
    esac
    shift
done

if [[ $SHOW_HELP -eq 1 || -z "$IMAGE_DIR" ]]; then
  cat <<EOF
Usage: build.sh [DIR] [OPTION]...

-c | --check            Check required packages
-C | --deepcheck        Check and compare checksum of required packages
-d | --check-dir [DIR]  The directory for validating packages (Docker for Windows only)
-h | --help             Show this help text
EOF
  exit 1
fi

cd `dirname "$0"`

if [[ $GEN_PKG_LIST -eq 1 ]]; then
  rm $PACKAGE_LIST.out
fi

if [[ $CHECK -eq 1 ]]; then
  echo "Start to check packages"
  if [[ ! -d "$CHECK_DIR" ]]; then
    echo "The specified directory could not access"
    exit 9
  fi

  while IFS=, read -r file md5sum; do
   echo -n -e "Check $file exists...\t"
   if [[ ! -f "$CHECK_DIR/$file" ]]; then
     echo " Not found."
     exit 9
   fi

   if [[ $DEEP_CHECK -eq 1 ]]; then
     res=`md5sum $CHECK_DIR/$file`
     if [[ $GEN_PKG_LIST -eq 1 ]]; then
       echo "$file,$res" >> $PACKAGE_LIST.out
     elif [[ "$md5sum" == "$res" ]]; then
       echo " MD5 does not match."
       exit 9
     fi
   fi

   echo " Found."
  done < $PACKAGE_LIST
fi

echo "Start to build"

# Create a newwork if it does not exist
if [[ -z `docker network ls -q --no-trunc -f "name=^build$"` ]]; then
  echo "Docker network build does not exist. Start to make it."
  docker network create build
  docker network ls -f "name=^build$"
fi

# Remove and run a container for HTTP server
images_exists=`docker ps -aq --no-trunc -f "name=^/images$"`
if [[ ! -z "$images_exists" ]]; then
    echo "Docker container image has been started. Remove it."
    docker rm -f "$images_exists"
fi

echo "Start a container - image"
docker run --rm --name images -h images --network build -v "$IMAGE_DIR":/usr/share/nginx/html:ro -d nginx
docker ps -f "name=^/images"

db2_exists=`docker images maximo/db2:$DB2_VER`
if [[ ! -z "$db2_exists" ]]; then
  echo "An old Db2 image exists. Remove it."
  docker rmi maximo/db2:$DB2_VER
  docker rmi maximo/db2:latest
fi

echo "Start to build a Db2 image"
docker build --rm -t maximo/db2:$DB2_VER -t maximo/db2:latest --network build maxdb
docker images maximo/db2

im_exists=`docker images maximo/ibmim:$IM_VER`
if [[ ! -z "$im_exists" ]]; then
  echo "An old IBM Installation Manager image exists. Remove it."
  docker rmi maximo/ibmim:$IM_VER
  docker rmi maximo/ibmim:latest
fi

echo "Start to build an IBM Installation Manager image"
docker build --rm -t maximo/ibmim:$IM_VER -t maximo/ibmim:latest --network build ibmim
docker images maximo/ibmim

was_exists=`docker images maximo/maxwas:$WAS_VER`
if [[ ! -z "$was_exists" ]]; then
  echo "An old WebSphere Application Server image exists. Remove it."
  docker rmi maximo/maxwas:$WAS_VER
  docker rmi maximo/maxwas:latest
fi

echo "Start to build a WebSphere Applicatoin Server image"
docker build --rm -t maximo/maxwas:$WAS_VER -t maximo/maxwas:latest --network build maxwas
docker images maximo/maxwas

dmgr_exists=`docker images maximo/maxdmgr:$WAS_VER`
if [[ ! -z "$dmgr_exists" ]]; then
  echo "An old WebSphere Application Server Deployment Manager image exists. Remove it."
  docker rmi maximo/maxdmgr:$WAS_VER
  docker rmi maximo/maxdmgr:latest
fi

echo "Start to build a WebSphere Applicatoin Server Deployment Manager image"
docker build --rm -t maximo/maxdmgr:$WAS_VER -t maximo/maxdmgr:latest --network build maxdmgr
docker images maximo/maxdmgr

app_exists=`docker images maximo/maxapps:$WAS_VER`
if [[ ! -z "$app_exists" ]]; then
  echo "An old WebSphere Application Server Node image exists. Remove it."
  docker rmi maximo/maxapps:$WAS_VER
  docker rmi maximo/maxapps:latest
fi

echo "Start to build a WebSphere Applicatoin Server Node image"
docker build --rm -t maximo/maxapps:$WAS_VER -t maximo/maxapps:latest --network build maxapps
docker images maximo/maxapps

web_exists=`docker images maximo/maxweb:$WAS_VER`
if [[ ! -z "$web_exists" ]]; then
  echo "An old WebSphere Application Server Web Server image exists. Remove it."
  docker rmi maximo/maxweb:$WAS_VER
  docker rmi maximo/maxweb:latest
fi

echo "Start to build a WebSphere Applicatoin Server Web Server image"
docker build --rm -t maximo/maxweb:$WAS_VER -t maximo/maxweb:latest --network build maxweb
docker images maximo/maxweb

maximo_exists=`docker images maximo/maximo:$MAXIMO_VER`
if [[ ! -z "$maximo_exists" ]]; then
  echo "An old Maximo Asset Management image exists. Remove it."
  docker rmi maximo/maximo:$MAXIMO_VER
  docker rmi maximo/maximo:latest
fi

echo "Start to build a Maximo Asset Management image"
docker build --rm -t maximo/maximo:$MAXIMO_VER -t maximo/maximo:latest --network build maximo
docker images maximo/maximo

#docker build -t maximo/maximo:$MAXIMO_VER -t maximo/maximo:latest --network build maximo

echo "Stop the images container."
docker stop images

echo "Done."
