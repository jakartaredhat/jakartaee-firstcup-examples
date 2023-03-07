####
# This Dockerfile is used in order to build a container that runs the Quarkus application in JVM mode
#
###
FROM registry.access.redhat.com/ubi8/openjdk-11:latest AS build

USER root
WORKDIR /build
RUN mkdir -p .mvn/wrapper
# Build dependency offline to streamline build
COPY mvnw* .
COPY .mvn/wrapper .mvn/wrapper
COPY pom.xml .
COPY dukes-age/pom.xml dukes-age/pom.xml
COPY dukes-age/src dukes-age/src
COPY firstcup-war/pom.xml firstcup-war/pom.xml
COPY firstcup-war/src firstcup-war/src

RUN ./mvnw dependency:go-offline

RUN ./mvnw package


# https://quay.io/repository/wildfly/wildfly
FROM quay.io/wildfly/wildfly
COPY --from=build /build/dukes-age/target/dukes-age.war /opt/jboss/wildfly/standalone/deployments/
COPY --from=build /build/firstcup-war/target/firstcup-war.war /opt/jboss/wildfly/standalone/deployments/

EXPOSE 8080
USER 1000

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
