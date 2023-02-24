FROM alpine:latest

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="sund version:- ${VERSION} Build-date:- ${BUILD_DATE}"

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-arm.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD rootfs /

# s6 overlay Download
ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

## updates
RUN \
  echo "**** Update OS ****" && \
  apk -U upgrade --no-cache && \
  tar xzf /tmp/s6overlay.tar.gz -C / && \
  echo "**** Install borgbackup and python3 pip ****" && \
  apk add vim bash borgbackup openrc openssh py3-pip --no-cache && \
  echo "**** pip3 install of borgmatic ****" && \
  pip3 install --upgrade borgmatic && \
  rm -rf /var/cache/apk/* && \
  rm /tmp/s6overlay.tar.gz

HEALTHCHECK CMD ps aux | grep 'crond -f\|borgmatic' | grep -v grep > /dev/null || exit 1

# Init
ENTRYPOINT [ "/init" ]
