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
MAXIMO_VER="${MAXIMO_VER:-7.6.1.2}"
IM_VER="${IM_VER:-1.8.8}"
WAS_VER="${WAS_VER:-9.0.0.10}"
DB2_VER="${DB2_VER:-11.1.4a}"

DOCKER="${DOCKER_CMD:-docker}"

BUILD_NETWORK_NAME="build"
IMAGE_SERVER_NAME="images"
IMAGE_SERVER_HOST_NAME="images"
NAME_SPACE="maximo"

REMOVE=0

# Usage: remove "tag name" "version" "product name"
function remove {
  image_id=`$DOCKER images -q --no-trunc $NAME_SPACE/$1:$2`
  if [[ ! -z "$image_id" ]]; then
    echo "An old $3 image exists. Remove it."
    container_ids=`$DOCKER ps -aq --no-trunc -f ancestor=$image_id`
    if [[ ! -z "$container_ids" ]]; then
      $DOCKER rm -f $container_ids
    fi
    $DOCKER rmi -f "$image_id"
  fi
}

# Usage: build "tag name" "version" "target directory name" "product name"
function build {
  echo "Start to build $4 image"
  $DOCKER build --rm -t $NAME_SPACE/$1:$2 -t $NAME_SPACE/$1:latest --network $BUILD_NETWORK_NAME $3

  exists=`$DOCKER images -q --no-trunc $NAME_SPACE/$1:$2`
  if [[ -z "$exists" ]]; then
    echo "Failed to create $4 image."
    exit 2
  fi

  echo "Completed $4 image creation."
}

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
      -r | --remove )
        REMOVE=1
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
-r | --remove           Remove images when an image exists in repository
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

if [[ $REMOVE -eq 1 ]]; then
  echo "Remove old images..."
  remove "db2" "$DB2_VER" "IBM Db2 Advanced Workgroup Server Edition"
  remove "maximo" "$MAXIMO_VER" "IBM Maximo Asset Management"
  remove "maxdmgr" "$WAS_VER" "IBM WebSphere Application Server Deployment Manager"
  remove "maxapps" "$WAS_VER" "IBM WebSphere Application Server Node"
  remove "maxweb" "$WAS_VER" "IBM HTTP Server"
  remove "maxwas" "$WAS_VER" "IBM WebSphere Application Server traditional base"
  remove "ibmim" "$IM_VER" "IBM Installation Manager"
fi

echo "Start to build..."

# Create a newwork if it does not exist
if [[ -z `$DOCKER network ls -q --no-trunc -f "name=^${BUILD_NETWORK_NAME}$"` ]]; then
  echo "Docker network build does not exist. Start to make it."
  $DOCKER network create ${BUILD_NETWORK_NAME}
  $DOCKER network ls -f "name=^${BUILD_NETWORK_NAME}$"
fi

# Remove and run a container for HTTP server
images_exists=`$DOCKER ps -aq --no-trunc -f "name=^/${IMAGE_SERVER_NAME}$"`
if [[ ! -z "$images_exists" ]]; then
    echo "Docker container images has been started. Remove it."
    $DOCKER rm -f "$images_exists"
fi

echo "Start a container - images"
$DOCKER run --rm --name ${IMAGE_SERVER_NAME} -h ${IMAGE_SERVER_HOST_NAME} --network ${BUILD_NETWORK_NAME} \
 -v "$IMAGE_DIR":/usr/share/nginx/html:ro -d nginx
$DOCKER ps -f "name=^/${IMAGE_SERVER_NAME}"

# Build IBM Db2 Advanced Workgroup Edition image
build "db2" "$DB2_VER" "maxdb" "IBM Db2 Advanced Workgroup Server Edition"

# Build IBM Installation Manager image
build "ibmim" "$IM_VER" "ibmim" "IBM Installation Manager"

# Build IBM WebSphere Application Server traditional base image
build "maxwas" "$WAS_VER" "maxwas" "IBM WebSphere Application Server traditional base"

# Build IBM WebSphere Application Server traditional Deployment Manager image
build "maxdmgr" "$WAS_VER" "maxdmgr" "IBM WebSphere Application Server Deployment Manager"

# Build IBM WebSphere Application Server traditional Node image
build "maxapps" "$WAS_VER" "maxapps" "IBM WebSphere Application Server Node"

# Build IBM HTTP Server image
build "maxweb" "$WAS_VER" "maxweb" "IBM HTTP Server"

# Build IBM Maximo Asset Management image
build "maximo" "$MAXIMO_VER" "maximo" "IBM Maximo Asset Management"

echo "Stop the images container."
$DOCKER stop "${IMAGE_SERVER_NAME}"

echo "Done."
