FROM alpine:3.14@sha256:234cb88d3020898631af0ccbbcca9a66ae7306ecd30c9720690858c1b007d2a0

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

# renovate: datasource=github-releases depName=hairyhenderson/gomplate
ENV GOMPLATE_VERSION="${GOMPLATE_VERSION:-v3.9.0}"
# renovate: datasource=github-releases depName=aptible/supercronic
ENV SUPERCRONIC_VERSION="${SUPERCRONIC_VERSION:-v0.1.12}"
# renovate: datasource=github-releases depName=thegeeklab/url-parser
ENV URL_PARSER_VERSION="${URL_PARSER_VERSION:-v0.2.5}"
# renovate: datasource=github-releases depName=thegeeklab/wait-for
ENV WAIT_FOR_VERSION="${WAIT_FOR_VERSION:-v0.2.0}"

RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/www -s /sbin/nologin -G nginx -g nginx nginx && \
    apk --update add --virtual .build-deps curl && \
    apk --update --no-cache add nginx ca-certificates && \
    rm -rf /var/www/localhost && \
    rm -rf /etc/nginx/conf.d && \
    curl -SsL -o /usr/local/bin/gomplate "https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64-slim" && \
    curl -SsL -o /usr/local/bin/supercronic "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64" && \
    curl -SsL -o /usr/local/bin/url-parser "https://github.com/thegeeklab/url-parser/releases/download/${URL_PARSER_VERSION}/url-parser-linux-amd64" && \
    curl -SsL -o /usr/local/bin/wait-for "https://github.com/thegeeklab/wait-for/releases/download/${WAIT_FOR_VERSION}/wait-for" && \
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
