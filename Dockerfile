# This image is based on docker:latest

# Build miller which is not available in the Alpine Linux repos (yet).
# https://github.com/johnkerl/miller/issues/293
FROM alpine AS miller-builder
WORKDIR /root
ARG miller_version=5.6.2
RUN apk add --no-cache curl
RUN curl -L https://github.com/johnkerl/miller/archive/v${miller_version}.tar.gz \
  | tar -xzf -
WORKDIR /root/miller-${miller_version}
RUN apk add --no-cache build-base automake autoconf libtool flex \
 && autoreconf -fiv
RUN ./configure --prefix=/ \
    --disable-shared --enable-static
RUN make install \
    mlrg_CFLAGS="" mlrp_CFLAGS="" CFLAGS="-O3"
    # We need those flags because the linker builds the executable
    # with -pg by default, which is not compatible with musl-libc.

FROM docker
RUN apk add --no-cache bash iproute2 net-tools
COPY --from=miller-builder /bin/mlr /usr/bin/mlr
COPY ./dockerveth/dockerveth.sh /usr/bin/dockerveth.sh
COPY ./netem-agent /usr/bin/netem-agent
ENTRYPOINT [ "/usr/bin/netem-agent" ]
CMD ["--"]
