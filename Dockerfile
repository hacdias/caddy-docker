FROM golang:1.15.2-buster

ENV CADDY_VERSION v2.2.0

RUN go get -u github.com/caddyserver/xcaddy/cmd/xcaddy; \
  xcaddy build $CADDY_VERSION --with github.com/caddy-dns/cloudflare; \
  mv caddy /usr/bin/caddy

FROM alpine:3.12

RUN apk add --no-cache ca-certificates mailcap

COPY --from=0 /usr/bin/caddy /usr/bin/caddy

RUN chmod +x /usr/bin/caddy; \
	caddy version

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/docker-library/golang/blob/1eb096131592bcbc90aa3b97471811c798a93573/1.14/alpine3.12/Dockerfile#L9
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

VOLUME /config
VOLUME /data

EXPOSE 80
EXPOSE 443

WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
