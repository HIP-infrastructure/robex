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

WORKDIR /apps/${APP_NAME}
COPY ./apps/${APP_NAME}/robex .

ENV APP_SPECIAL="terminal"
ENV APP_CMD_PREFIX="export PATH=/apps/${APP_NAME}:${PATH}"
ENV APP_CMD=""
ENV PROCESS_NAME="ROBEX"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
