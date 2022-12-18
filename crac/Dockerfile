FROM ubuntu:18.04 AS builder

RUN apt-get update && apt-get install git curl -y procps&& rm -rf /var/lib/apt/lists/*

WORKDIR /home/app
ENV JAVA_HOME /home/app/openjdk-17-crac+3_linux-x64

COPY temp/openjdk-17-crac+3_linux-x64.tar.gz ./
RUN tar -xvzf openjdk-17-crac+3_linux-x64.tar.gz

RUN curl 'https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz' \
  -o apache-maven-3.8.6-bin.tar.gz
RUN tar -xvzf apache-maven-3.8.6-bin.tar.gz

RUN git clone -b feature/addLogging https://github.com/Keymaster65/example-jetty.git src

RUN cd src && ../apache-maven-3.8.6/bin/mvn package

COPY entrypoint.sh ./

FROM ubuntu:18.04 AS app

RUN apt-get update && apt-get install curl -y procps&& rm -rf /var/lib/apt/lists/*

WORKDIR /home/app
COPY --from=builder /home/app/openjdk-17-crac+3_linux-x64 ./openjdk-17-crac+3_linux-x64
ENV JAVA_HOME /home/app/openjdk-17-crac+3_linux-x64

COPY --from=builder /home/app/src/target/example-jetty-1.0-SNAPSHOT.jar ./example-jetty-1.0-SNAPSHOT.jar
COPY --from=builder /home/app/src/target/dependency ./dependency
COPY --from=builder /home/app/entrypoint.sh ./

RUN groupadd --gid 1000 app \
    && useradd --uid 1000 --gid app --password app app \
    && mkdir cr \
    && chown app:app cr
USER app

ENTRYPOINT ["/home/app/entrypoint.sh"]


