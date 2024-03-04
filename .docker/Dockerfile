FROM alpine:3.19
RUN apk add github-cli jq
WORKDIR /data
COPY entrypoint.sh /data/
RUN chmod a+x /data/entrypoint.sh
ENTRYPOINT [ "sh", "-c" ]
CMD ["/data/entrypoint.sh"]