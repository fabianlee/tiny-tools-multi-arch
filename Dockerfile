FROM alpine:3.18.3

# latest certs
RUN apk add ca-certificates --no-cache && update-ca-certificates

# timezone support
ENV TZ=UTC
RUN apk add --update tzdata --no-cache &&\
    cp /usr/share/zoneinfo/${TZ} /etc/localtime &&\
    echo $TZ > /etc/timezone

# ==additional apk packages==
# https://pkgs.alpinelinux.org/contents?branch=edge&name=bind%2dtools&arch=x86&repo=main
# bind-tools: dig,nslookup for DNS lookup
# netcat-opensbd: nc for netcat
# jq: json parsing
# chrony: ntpdate for checking
# mutt,ssmtp: SMTP client testing
RUN apk add --update --no-cache \
  curl bind-tools netcat-openbsd coreutils jq chrony mutt ssmtp

# standard Docker arguments
ARG TARGETPLATFORM
ARG BUILDPLATFORM
# custom build argument
ARG BUILD_TIME
RUN echo "[$BUILD_TIME] building on host that is $BUILDPLATFORM, for the target architecture $TARGETPLATFORM" > /build.log
