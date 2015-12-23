FROM ibmcom/websphere-liberty:webProfile6

User root

RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense jaxws-2.2
RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense javaMail-1.5
RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense wasJmsClient-1.1
RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense jmsmdb-3.1
RUN /opt/ibm/wlp/bin/featureManager install --acceptLicense wasjmsserver-1.0

COPY server.xml /config/
COPY jvm.options /config/

