# Building and deploying an IBM Maximo Asset Management V7.6 with Feature Pack image to Docker
------------------------------------------------------------------------------------

Maximo on Docker enables to run Maximo Asset Management on Docker. The images are deployed fine-grained services instead of single instance. The following instructions describe how to set up IBM Maximo Asset Management V7.6 Docker images. This images consist of several components e.g. WebSphere, Db2, and Maximo installation program.

![Componets of Docker Images](https://raw.githubusercontent.com/nishi2go/maximo-docker/master/maximo-docker.svg)

## Required packages
--------------------

* IBM Maximo Asset Management V7.6.1 binaries from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html)

  IBM Enterprise Deployment (formerly known as IBM Installation Manager) binaries:
  * IED_V1.8.8_Wins_Linux_86.zip

  IBM Maximo Asset Management V7.6.1 binaries:
  * MAM_7.6.1_LINUX64.tar.gz

  IBM WebSphere Application Server traditional V9 binaries:
  * WAS_ND_V9.0_MP_ML.zip

  IBM HTTP Server and WebSphere Plugin V9 binaries:
  * was.repo.9000.ihs.zip
  * was.repo.9000.plugins.zip

  IBM Java SDK V8 binaries:
  * sdk.repo.8030.java8.linux.zip

  IBM Db2 Advanced Workgroup Edition V11.1 binaries:
  * DB2_AWSE_REST_Svr_11.1_Lnx_86-64.tar.gz

* Feature Pack/Fix Pack binaries from [Fix Central](http://www-933.ibm.com/support/fixcentral/)

  IBM WebSphere Application Server traditional Fixpack V9.0.0.7 binaries:
  * 9.0.0-WS-WAS-FP007.zip

  IBM HTTP Server Fixpack V9.0.0.7 binaries:
  * 9.0.0-WS-IHSPLG-FP007.zip

  IBM Java SDK Fixpack V8.0.5.16 Installation Manager Repository binaries:
  * ibm-java-sdk-8.0-5.16-linux-x64-installmgr.zip

  IBM Db2 Server V11.1 Fix Pack 3
  * v11.1.3fp3_linuxx64_server_t.tar.gz

## Building IBM Maximo Asset Management V7.6 image by using build tool
------------------------------------------------------

Prerequisites: all binaries must be accessible via a web server during building phase.

You can use a tool for building docker images by using the build tool.

Usage:
```
Usage: build.sh [DIR] [OPTION]...

-c | --check            Check required packages
-C | --deepcheck        Check and compare checksum of required packages
-r | --remove           Remove images when an image exists in repository
-d | --check-dir [DIR]  The directory for validating packages (Docker for Windows only)
-h | --help             Show this help text
```

Procedures:
1. Place the downloaded Maximo, IBM Db2, IBM Installation Manager and IBM WebSphere Application Server traditional binaries on a directory.
2. Clone this repository.
    ```bash
    git clone https://github.com/nishi2go/maximo-docker.git
    ```
3. Move to the directory.
    ```bash
    cd maximo-docker
    ```
4. Run build tool.
   ```bash
   bash build.sh [Image directory] [-c] [-C] [-r]
   ```

   Example:
   ```bash
   bash build.sh /images -c -r
   ```

   Example for Docker for Windows:
   ```bash
   bash build.sh "C:/images" -c -r -d /images
   ```
   Note 1: This script works on Windows Subsystem on Linux.<br>
   Note 2: md5sum is required. For Mac, install it manually - https://raamdev.com/2008/howto-install-md5sum-sha1sum-on-mac-os-x/
5. Run containers by using the Docker Compose file to create and deploy new instances.
    ```bash
    docker-compose up -d
    ```
    Note: It will take 3-4 hours (depend on your machine spec) to complete the installation.
    Note: To change the default passwords, edit XYZ_PASSWORD environment variables in docker-compose.yml file. Do not use a different value to the same environment variable across services.
6. Make sure to be accessible to Maximo login page: http://hostname/maximo

## Building IBM Maximo Asset Management V7.6 image by manually
------------------------------------------------------

Prerequisites: all binaries must be accessible via a web server during building phase.

Procedures:
1. Place the downloaded Maximo, IBM Db2, IBM Installation Manager and IBM WebSphere Application Server traditional binaries on a directory
2. Create docker network for build with:
    ```bash
    docker network create build
    ```
3. Run nginx docker image to be able to download binaries from HTTP.
    ```bash
    docker run --name images -h images --network build \
    -v [Image directory]:/usr/share/nginx/html:ro -d nginx
    ```
4. Clone this repository.
    ```bash
    git clone https://github.com/nishi2go/maximo-docker.git
    ```
5. Move to the directory.
    ```bash
    cd maximo-docker
    ```
6. Build Docker images:
    Build Db2 image:
    ```bash
    docker build -t maximo/db2:11.1.3 -t maximo/db2:latest --network build maxdb
    ```
    Build IBM Enterprise Deployment (IBM Installation Manager) image:
    ```bash
    docker build -t maximo/ibmim:1.8.8 -t maximo/ibmim:latest --network build ibmim
    ```
    Build WebSphere Application Server base image:
    ```bash
    docker build -t maximo/maxwas:9.0.0.7 -t maximo/maxwas:latest --network build maxwas
    ```
    Build WebSphere Application Server Deployment Manager image:
    ```bash
    docker build -t maximo/maxdmgr:9.0.0.7 -t maximo/maxdmgr:latest maxdmgr
    ```
    Build WebSphere Application Server AppServer image:
    ```bash
    docker build -t maximo/maxapps:9.0.0.7 -t maximo/maxapps:latest maxapps
    ```
    Build IBM HTTP Server image:
    ```bash
    docker build -t maximo/maxweb:9.0.0.7 -t maximo/maxweb:latest --network build maxweb
    ```
    Build Maximo Asset Management Installation image:
    ```bash
    docker build -t maximo/maximo:7.6.1 -t maximo/maximo:latest --network build maximo
    ```
    Note: If the build has failed during Maximo Feature Pack installation, run the docker build again.
7. Run containers by using the Docker Compose file to create and deploy new instances.
    ```bash
    docker-compose up -d
    ```
    Note: It will take 3-4 hours (depend on your machine spec) to complete the installation.
    Note: To change the default passwords, edit XYZ_PASSWORD environment variables in docker-compose.yml file. Do not use a different value to the same environment variable across services.
8. Make sure to be accessible to Maximo login page: http://hostname/maximo

## Skip the maxinst process in starting up the maxdb container by using Db2 restore command
------------------------------------------------------

[Maxinst program](http://www-01.ibm.com/support/docview.wss?uid=swg21314938) supports to initialize and create a Maximo database that called during the "deployConfiguration" process in the Maximo installer. This process is painfully slow because it creates more than thousand tables from scratch. To skip the process, you can use a backup database to restore during first boot time in a maxdb service. So then, it can reduce the creation time for containers from second time.

Procedures:
1. Build container images first (follow above instructions)
2. Move to the cloned directory.
    ```bash
    cd maximo-docker
    ```
3. Make a backup directory.
    ```bash
    mkdir ./backup
    ```
4. Uncomment the following volume configuration in docker-compose.yml.
    ```yaml
      maxdb:
        volumes:
          - type: bind
            source: ./backup
            target: /backup
    ```
5. Run containers by using the Docker Compose file. (follow above instructions)
6. Take a backup from the maxdb service by using a backup tool.
    ```bash
    docker-compose exec maxdb /work/backup.sh maxdb76 /backup
    ```
    Note: Backup image must be only one in the directory. Backup task must fail when more than two images in it.

So that, now you can create the containers from the backup image that is stored in the directory.
