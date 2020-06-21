FROM openfaas/classic-watchdog:0.18.1 as watchdog

FROM alpine:3.11

RUN mkdir -p /home/app
RUN apk add --no-cache nmap
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Add non root user
RUN addgroup -S app && adduser app -S -G app
RUN chown app /home/app

WORKDIR /home/app

USER app

# Populate example here - i.e. "cat", "sha512sum" or "node index.js"
#ENV fprocess="cat"
ENV fprocess="xargs nmap"
# Set to true to see request in function logs
ENV write_debug="false"
ENV read_timeout="60"
ENV write_timeout="60"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
