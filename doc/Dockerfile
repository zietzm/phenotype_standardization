FROM python:3.8-slim-buster

RUN apk add --no-cache bash findutils
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
