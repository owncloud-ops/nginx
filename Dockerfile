FROM alpine:3.11@sha256:0bd0e9e03a022c3b0226667621da84fc9bf562a9056130424b5bfbd8bcb0397f

LABEL maintainer="ownCloud GmbH <devops@owncloud.com>" \
    org.label-schema.name="Nginx" \
    org.label-schema.vendor="ownCloud GmbH" \
    org.label-schema.schema-version="1.0"

RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/www -s /sbin/nologin -G nginx -g nginx nginx && \
    apk --update add --virtual .build-deps curl && \
    apk --update --no-cache add nginx ca-certificates && \
    rm -rf /var/www/localhost && \
    rm -rf /etc/nginx/conf.d && \
    curl -SsL -o /usr/local/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v3.8.0/gomplate_linux-amd64-slim && \
    curl -SsL -o /usr/local/bin/supercronic https://github.com/aptible/supercronic/releases/download/v0.1.9/supercronic-linux-amd64 && \
    curl -SsL -o /usr/local/bin/url-parser https://github.com/thegeeklab/url-parser/releases/download/v0.1.1/url-parser-linux-amd64 && \
    curl -SsL -o /usr/local/bin/wait-for https://raw.githubusercontent.com/thegeeklab/wait-for/master/wait-for && \
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
