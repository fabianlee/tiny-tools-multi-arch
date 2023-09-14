#ARG ARCH=
#FROM ${ARCH}/alpine:3.18.3
FROM alpine:3.18.3

# latest certs
RUN apk add ca-certificates --no-cache && update-ca-certificates

# timezone support
ENV TZ=UTC
RUN apk add --update tzdata --no-cache &&\
    cp /usr/share/zoneinfo/${TZ} /etc/localtime &&\
    echo $TZ > /etc/timezone

# ==utilities==
# https://pkgs.alpinelinux.org/contents?branch=edge&name=bind%2dtools&arch=x86&repo=main
# bind-tools: dig,nslookup for DNS lookup
# netcat-opensbd: nc for netcat
# jq: json parsing
# chrony: ntpdate for checking
# mutt,ssmtp: SMTP client testing
RUN apk add --update --no-cache \
  curl bind-tools netcat-openbsd coreutils jq chrony mutt ssmtp
