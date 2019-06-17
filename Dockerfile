FROM alpine

RUN apk --no-cache add bash git subversion


COPY syncToSVN.sh syncToSVN.sh 
COPY docker-entrypoint.sh docker-entrypoint.sh 
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

