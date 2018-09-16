FROM alpine:3.8

ENV VERSION 1.1.0

ENV UID 1337
ENV GID 1337
ENV USER healthchecks
ENV GROUP healthchecks

RUN addgroup -S ${GROUP} -g ${GID} && adduser -D -S -u ${UID} ${USER} ${GROUP} && \
    apk update && apk add --no-cache curl python3 supervisor bash && \
    mkdir -p /opt/healthchecks && curl -sSL https://github.com/healthchecks/healthchecks/archive/v${VERSION}.tar.gz | tar xz -C /opt/healthchecks --strip-components=1 && \
    apk add --virtual .build-deps gcc python3-dev musl-dev postgresql-dev && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    cd /opt/healthchecks && pip3 install -r requirements.txt --no-cache-dir  && \
    chown ${USER}:${GROUP} -R /opt/healthchecks && \
    apk --purge del .build-deps
WORKDIR /opt/healthchecks

COPY scripts/entrypoint.sh /
COPY scripts/supervisord.conf /

RUN chmod +x /entrypoint.sh

EXPOSE 8000

USER healthchecks

ENTRYPOINT ["/entrypoint.sh"]

CMD ["supervisord","-c","/supervisord.conf"]
