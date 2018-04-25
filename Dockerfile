FROM golang:alpine as builder
MAINTAINER Jessica Frazelle <jess@linux.com>

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go

RUN	apk add --no-cache \
	ca-certificates

COPY . /go/src/github.com/jessfraz/bpfps

RUN set -x \
	&& apk add --no-cache --virtual .build-deps \
		git \
		gcc \
		libc-dev \
		libgcc \
		make \
	&& cd /go/src/github.com/jessfraz/bpfps \
	&& make static \
	&& mv bpfps /usr/bin/bpfps \
	&& apk del .build-deps \
	&& rm -rf /go \
	&& echo "Build complete."

FROM scratch

COPY --from=builder /usr/bin/bpfps /usr/bin/bpfps
COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs

ENTRYPOINT [ "bpfps" ]
CMD [ "--help" ]
