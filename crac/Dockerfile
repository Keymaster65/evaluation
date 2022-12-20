FROM ubuntu:18.04 AS builder

RUN apt-get update && apt-get install git curl -y procps&& rm -rf /var/lib/apt/lists/*

WORKDIR /home/app
ENV JAVA_HOME /home/app/openjdk-17-crac+3_linux-x64

COPY temp/openjdk-17-crac+3_linux-x64.tar.gz ./
RUN tar -xvzf openjdk-17-crac+3_linux-x64.tar.gz

ARG CACHEBUST_FORCE=8

RUN git clone -b experiment/crac https://github.com/Keymaster65/copper2go.git src

RUN cd src && ./gradlew :copper2go-application:assemble

ARG CACHEBUST_PULL=2

RUN cd src && git pull && git log && ./gradlew :copper2go-application:assemble

RUN    tar -xvf src/copper2go-application/build/distributions/copper2go-application.tar
COPY entrypoint.sh ./

FROM ubuntu:18.04 AS app

RUN apt-get update && apt-get install curl -y procps&& rm -rf /var/lib/apt/lists/*

WORKDIR /home/app
COPY --from=builder /home/app/openjdk-17-crac+3_linux-x64 ./openjdk-17-crac+3_linux-x64
ENV JAVA_HOME /home/app/openjdk-17-crac+3_linux-x64

COPY --from=builder /home/app/copper2go-application/ ./
COPY --from=builder /home/app/entrypoint.sh ./

RUN groupadd --gid 1000 app \
    && useradd --uid 1000 --gid app --password app app \
    && mkdir cr \
    && chown app:app cr \
    && mkdir .copper \
    && chown app:app .copper \
    && mkdir .config \
    && chown app:app .config
USER app

ENTRYPOINT ["/home/app/entrypoint.sh"]


