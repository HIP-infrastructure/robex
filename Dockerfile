ARG CI_REGISTRY_IMAGE
ARG TAG
ARG APP_NAME
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="paoloemilio.mazzon@unipd.it"


ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG TAG
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}/

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update -q && \
    apt-get install --no-install-recommends -qy \
    unzip \
    ca-certificates \
    curl && \
    curl -sSL 'https://www.nitrc.org/frs/download.php/5994/ROBEXv12.linux64.tar.gz/?i_agree=1&download_now=1' -o ${APP_NAME}${APP_VERSION}.tar.gz && \
    tar -zxf ${APP_NAME}${APP_VERSION}.tar.gz && \
    rm -f ${APP_NAME}${APP_VERSION}.tar.gz && \
    mv ROBEX ${APP_NAME} && \
    chown -R 0:0 ${APP_NAME} && \
    chmod 755 /apps/${APP_NAME}/${APP_NAME} && \
    chmod -R go-w /apps/${APP_NAME}/${APP_NAME} && \
    chmod 644 /apps/${APP_NAME}/${APP_NAME}/dat/* /apps/${APP_NAME}/${APP_NAME}/ref_vols/* && \
    apt-get remove -y --purge \
    curl && \
    apt-get autoremove -y --purge

ENV APP_SPECIAL="terminal"
ENV APP_CMD_PREFIX="export PATH=/apps/${APP_NAME}/${APP_NAME}:${PATH}"
ENV APP_CMD=""
ENV PROCESS_NAME="ROBEX"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
