FROM docker.io/amd64/alpine:3.18@sha256:c5c5fda71656f28e49ac9c5416b3643eaa6a108a8093151d6d1afc9463be8e33

LABEL maintainer="ownCloud DevOps <devops@owncloud.com>"
LABEL org.opencontainers.image.authors="ownCloud DevOps <devops@owncloud.com>"
LABEL org.opencontainers.image.title="NGINX Web"
LABEL org.opencontainers.image.url="https://github.com/owncloud-ops/nginx"
LABEL org.opencontainers.image.source="https://github.com/owncloud-ops/nginx"
LABEL org.opencontainers.image.documentation="https://github.com/owncloud-ops/nginx"

ARG GOMPLATE_VERSION
ARG SUPERCRONIC_VERSION
ARG URL_PARSER_VERSION
ARG WAIT_FOR_VERSION
ARG CONTAINER_LIBRARY_VERSION

# renovate: datasource=github-releases depName=hairyhenderson/gomplate
ENV GOMPLATE_VERSION="${GOMPLATE_VERSION:-v3.11.5}"
# renovate: datasource=github-releases depName=aptible/supercronic
ENV SUPERCRONIC_VERSION="${SUPERCRONIC_VERSION:-v0.2.26}"
# renovate: datasource=github-releases depName=thegeeklab/url-parser
ENV URL_PARSER_VERSION="${URL_PARSER_VERSION:-v1.0.4}"
# renovate: datasource=github-releases depName=thegeeklab/wait-for
ENV WAIT_FOR_VERSION="${WAIT_FOR_VERSION:-v0.4.2}"
# renovate: datasource=github-releases depName=owncloud-ops/container-library
ENV CONTAINER_LIBRARY_VERSION="${CONTAINER_LIBRARY_VERSION:-v0.1.0}"

RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/www -s /sbin/nologin -G nginx -g nginx nginx && \
    apk --update add --virtual .build-deps curl && \
    apk --update --no-cache add nginx ca-certificates && \
    rm -rf /var/www/localhost && \
    rm -rf /etc/nginx/conf.d && \
    curl -SsfL -o /usr/local/bin/gomplate "https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64" && \
    curl -SsfL -o /usr/local/bin/supercronic "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64" && \
    curl -SsfL -o /usr/local/bin/url-parser "https://github.com/thegeeklab/url-parser/releases/download/${URL_PARSER_VERSION}/url-parser-linux-amd64" && \
    curl -SsfL -o /usr/local/bin/wait-for "https://github.com/thegeeklab/wait-for/releases/download/${WAIT_FOR_VERSION}/wait-for" && \
    curl -SsfL "https://github.com/owncloud-ops/container-library/releases/download/${CONTAINER_LIBRARY_VERSION}/container-library.tar.gz" | tar xz -C / && \
    chmod 755 /usr/local/bin/gomplate && \
    chmod 755 /usr/local/bin/supercronic && \
    chmod 755 /usr/local/bin/url-parser && \
    chmod 755 /usr/local/bin/wait-for && \
    touch /run/nginx.pid && \
    chown nginx /run/nginx.pid && \
    chown -R nginx /var/log/nginx && \
    mkdir -p /var/cache/nginx && \
    chown -R nginx /var/cache/nginx && \
    chmod -R 750 /var/cache/nginx && \
    chown -R nginx:nginx /var/www && \
    chmod -R 750 /var/www && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

ADD overlay/ /

EXPOSE 8080

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
