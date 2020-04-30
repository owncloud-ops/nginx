FROM alpine:3.11

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
    curl -SsL -o /usr/local/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v3.5.0/gomplate_linux-amd64-slim && \
    curl -SsL -o /usr/local/bin/supercronic https://github.com/aptible/supercronic/releases/download/v0.1.9/supercronic-linux-amd64 && \
    curl -SsL -o /usr/local/bin/url-parser https://github.com/xoxys/url-parser/releases/download/v0.1.0/url-parser-0.1.0-linux-amd64 && \
    curl -SsL -o /usr/local/bin/wait-for https://raw.githubusercontent.com/xoxys/wait-for/master/wait-for && \
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
