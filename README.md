# Building and deploying an IBM Maximo Asset Management V7.6 with Feature Pack image to Docker
------------------------------------------------------------------------------------

Maximo on Docker enables to run Maximo Asset Management on Docker. The images are deployed fine-grained services instead of single instance. The following instructions describe how to set up IBM Maximo Asset Management V7.6 Docker images. This images consist of several components e.g. WebSphere, Db2, and Maximo installation program.

![Componets of Docker Images](https://raw.githubusercontent.com/nishi2go/maximo-docker/master/maximo-docker.png)

## Required packages
--------------------

* IBM Installation Manager binaries from [Installation Manager 1.8 download documents](http://www-01.ibm.com/support/docview.wss?uid=swg24037640)

  IBM Installation Manager binaries:
  * agent.installer.linux.gtk.x86_64_1.8.0.20140902_1503.zip

* IBM Maximo Asset Management V7.6 binaries from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html)

  IBM Maximo Asset Management V7.6 binaries:
  * MAM_7.6.0.0_LINUX64.tar.gz

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

  IBM Maximo Asset Management V7.6 Feature Pack 9 binaries:
  * MAMMTFP7609IMRepo.zip

  IBM WebSphere Application Server traditional Fixpack V9.0.0.7 binaries:
  * 9.0.0-WS-WAS-FP007.zip

  IBM HTTP Server Fixpack V9.0.0.7 binaries:
  * 9.0.0-WS-IHSPLG-FP007.zip

  IBM Java SDK Fixpack V8.0.5.16 Installation Manager Repository binaries:
  * ibm-java-sdk-8.0-5.16-linux-x64-installmgr.zip

  IBM Db2 Server V11.1 Fix Pack 3
  * v11.1.3fp3_linuxx64_server_t.tar.gz

## Building the IBM Maximo Asset Management V7.6 image
------------------------------------------------------

Prereq: all binaries should be accessible via a web server during building phase.

1. Place the downloaded IBM Installation Manager and IBM WebSphere Application Server traditional binaries on a directory
2. Create docker network for build with:
    ```bash
    docker network create build
    ```
3. Run nginx docker image to be able to download binaries from HTTP
    ```bash
    docker run --name images -h images --network build \
    -v <Image directory>:/usr/share/nginx/html:ro -d nginx
    ```
4. Clone this repository
    ```bash
    git clone https://github.com/nishi2go/maximo-docker.git
    ```
5. Move to the directory
    ```bash
    cd maximo-docker
    ```
6. Build Docker images:
    Build Db2 image:
    ```bash
    docker build -t maximo/db2:11.1.3 -t maximo/db2:latest --network build maxdb
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
    docker build -t maximo/maximo:7.6.0.9 -t maximo/maximo:latest --network build maximo
    ```
    Note: If the build has failed during Maximo Feature Pack installation, run the docker build again.
7. Run containers by using the Docker Compose file to create and deploy instances:
    ```bash
    docker-compose up -d
    ```
    Note: It will take 3-4 hours (depend on your machine) to complete the installation.
8. Make sure to be accessible to Maximo login page: http://hostname/maximo
