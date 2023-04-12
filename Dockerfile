FROM alpine

RUN apk --no-cache add \
    bash \
    curl \
    git \
    patch \
    zip \
    fontforge \
    py3-fontforge

COPY src /src

RUN mkdir /output \
    && adduser -D -H user \
    && chown user /output

USER user
WORKDIR /output

ENTRYPOINT ["/src/install.sh"]
