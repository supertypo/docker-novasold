FROM alpine:latest AS builder

ARG REPO_URL
ARG VERSION

ENV ARCHIVE_URL=${REPO_URL}/releases/download/${VERSION}/${VERSION}-Enigma-Ubuntu20.04.zip

RUN cd /tmp && \
  wget $ARCHIVE_URL 2>&1 && \
  mkdir novasol && \
  cd novasol && \
  unzip ../$(basename $ARCHIVE_URL) && \
  chmod 755 *

##
# novasold image
##
FROM debian:stable-slim

ENV APP_USER=novasold \
  APP_UID=45500 \
  APP_DIR=/app \
  APP_DATA_DIR=/app/data

EXPOSE 45500
EXPOSE 45501

WORKDIR $APP_DIR

ENV PATH=$APP_DIR:$PATH

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    dumb-init && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p $APP_DATA_DIR && \
  groupadd -r -g $APP_UID $APP_USER && \
  useradd -d $APP_DATA_DIR -r -m -s /sbin/nologin -g $APP_USER -u $APP_UID $APP_USER && \
  chown $APP_USER:$APP_USER $APP_DATA_DIR

COPY --from=builder /tmp/novasol/NovaSold $APP_DIR/novasold

USER $APP_USER

ENTRYPOINT ["dumb-init", "--"]

CMD novasold --rpc-bind-ip 0.0.0.0 --log-file /dev/null

