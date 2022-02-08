FROM tier/shib-idp:latest

# The build args below can be used at build-time to tell the build process where to find your config files.  This is for a completely burned-in config.
ARG TOMCFG=config/tomcat
ARG TOMCERT=credentials/tomcat
ARG TOMWWWROOT=wwwroot
ARG SHBCFG=config/shib-idp/conf
ARG SHBCREDS=credentials/shib-idp
ARG SHBVIEWS=config/shib-idp/views
ARG SHBEDWAPP=config/shib-idp/edit-webapp
ARG SHBMSGS=config/shib-idp/messages
ARG SHBMD=config/shib-idp/metadata

# copy in those needed config files
ADD ${TOMCFG} /usr/local/tomcat/conf
ADD ${TOMCERT} /opt/certs
ADD ${TOMWWWROOT} /usr/local/tomcat/webapps/ROOT
ADD ${SHBCFG} /opt/shibboleth-idp/conf
ADD ${SHBCREDS} /opt/shibboleth-idp/credentials
ADD ${SHBVIEWS} /opt/shibboleth-idp/views
#ADD ${SHBEDWAPP} /opt/shibboleth-idp/edit-webapp
#ADD ${SHBMSGS} /opt/shibboleth-idp/messages
ADD ${SHBMD} /opt/shibboleth-idp/metadata

# new for 4.1.0: install the Duo OIDC integration
#      https://wiki.shibboleth.net/confluence/display/IDPPLUGINS/DuoOIDCAuthnConfiguration
# For unattended install of plugins, trust must be manually bootstrapped.  You should never automate the retreival of this file (like this) for production.
#ADD https://github.internet2.edu/raw/docker/ShibbIdP_ConfigBuilder_Container/master/oidc-common-truststore.asc /opt/shibboleth-idp/credentials/net.shibboleth.idp.plugin.authn.duo.nimbus/truststore.asc
#ADD https://github.internet2.edu/raw/docker/ShibbIdP_ConfigBuilder_Container/master/duo-oidc-truststore.asc /opt/shibboleth-idp/credentials/net.shibboleth.oidc.common/truststore.asc
#install the plugins
#RUN /opt/shibboleth-idp/bin/plugin.sh --noPrompt -i https://shibboleth.net/downloads/identity-provider/plugins/oidc-common/1.0.0/oidc-common-dist-1.0.0.zip
#RUN /opt/shibboleth-idp/bin/plugin.sh --noPrompt -i https://shibboleth.net/downloads/identity-provider/plugins/duo-oidc/1.0.0/idp-plugin-duo-nimbus-dist-1.0.0.zip

ADD webauthn/opt/shibboleth-idp/edit-webapp /opt/shibboleth-idp/edit-webapp
ADD webauthn/opt/shibboleth-idp/flows /opt/shibboleth-idp/flows
ADD webauthn/opt/shibboleth-idp/conf /opt/shibboleth-idp/conf
ADD webauthn/opt/shibboleth-idp/views /opt/shibboleth-idp/views
ADD webauthn/opt/shibboleth-idp/credentials /opt/shibboleth-idp/credentials
RUN sed -i '/^#idp.authn.flows / s/.*/idp.authn.flows=WebAuthn/' /opt/shibboleth-idp/conf/authn/authn.properties
RUN sed -i '/^idp.additionalProperties=/ s/$/, \/conf\/authn\/WebAuthn.properties/' /opt/shibboleth-idp/conf/idp.properties
RUN sed -i '/ldapURL=/ s/$/ trustFile="%{idp.attribute.resolver.LDAP.trustCertificates}"/' /opt/shibboleth-idp/conf/attribute-resolver.xml
RUN cd /opt/shibboleth-idp/edit-webapp/WEB-INF/classes; export CLASSPATH=/opt/shibboleth-idp/dist/webapp/WEB-INF/lib/*:/opt/shibboleth-idp/edit-webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*; javac edu/duke/oit/idms/idp/authn/webauthn/*.java; cd /opt/shibboleth-idp/bin/; ./build.sh -Didp.target.dir=/opt/shibboleth-idp
