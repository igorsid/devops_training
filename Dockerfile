FROM tomcat:jre8

ARG nxhost
ARG version

ENV CATALINA_HOME /usr/local/tomcat

WORKDIR $CATALINA_HOME/webapps

RUN curl -o task7.war "http://${nxhost}:8081/nexus/content/repositories/task7/${version}/task7.war"

EXPOSE 8080
