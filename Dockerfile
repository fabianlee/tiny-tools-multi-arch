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
# yq: yaml parsing
# ntpsec: ntpdig for ntp client time query (ntpdig pool.ntp.org)
# mutt,ssmtp: SMTP client testing
RUN apk add --update --no-cache \
  curl bind-tools netcat-openbsd coreutils jq ntpsec mutt ssmtp

# standard Docker arguments
ARG TARGETPLATFORM
ARG BUILDPLATFORM
# custom build arguments
ARG BUILD_TIME
ARG GITREF
# persist these build time arguments into container as debug
RUN echo "[$BUILD_TIME] [$GITREF] building on host that is $BUILDPLATFORM, for the target architecture $TARGETPLATFORM" > /build.log
