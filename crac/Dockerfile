FROM ubuntu:18.04 AS builder

RUN apt-get update && apt-get install git curl -y procps&& rm -rf /var/lib/apt/lists/*

WORKDIR /home/app
ENV JAVA_HOME /home/app/zulu17.44.55-ca-crac-jdk17.0.8.1-linux_x64

COPY temp/zulu17.44.55-ca-crac-jdk17.0.8.1-linux_x64.tar.gz ./
RUN tar -xvzf zulu17.44.55-ca-crac-jdk17.0.8.1-linux_x64.tar.gz

RUN curl 'https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz' \
  -o apache-maven-3.8.8-bin.tar.gz
RUN tar -xvzf apache-maven-3.8.8-bin.tar.gz

RUN git clone -b feature/addLogging https://github.com/Keymaster65/example-jetty.git src

RUN cd src && ../apache-maven-3.8.8/bin/mvn package

COPY entrypoint.sh ./

#FROM bitnami/minideb as app

# FROM debian:11 as app
FROM ubuntu:23.04 AS app
# not working FROM ubuntu:23.04 AS app

RUN apt-get update && apt-get install curl -y procps&& rm -rf /var/lib/apt/lists/*

WORKDIR /home/app
COPY --from=builder /home/app/zulu17.44.55-ca-crac-jdk17.0.8.1-linux_x64 ./zulu17.44.55-ca-crac-jdk17.0.8.1-linux_x64
ENV JAVA_HOME /home/app/zulu17.44.55-ca-crac-jdk17.0.8.1-linux_x64

COPY --from=builder /home/app/src/target/example-jetty-1.0-SNAPSHOT.jar ./example-jetty-1.0-SNAPSHOT.jar
COPY --from=builder /home/app/src/target/dependency ./dependency
COPY --from=builder /home/app/entrypoint.sh ./

RUN groupadd --gid 1010 app \
    && useradd --uid 1010 --gid app --password app app \
    && mkdir cr \
    && chown app:app cr
USER app

ENTRYPOINT ["/home/app/entrypoint.sh"]


