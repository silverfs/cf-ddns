FROM alpine:latest

RUN apk add --no-cache dcron jq curl

# Create non-root user
RUN adduser -D -u 1000 cronuser

# Copy the script and set permissions
COPY cf_ddns /home/cronuser/cf_ddns
RUN chown cronuser:cronuser /home/cronuser/cf_ddns && chmod +x /home/cronuser/cf_ddns

# Set up crontab for non-root user
COPY crontab /var/spool/cron/crontabs/cronuser
RUN chown cronuser:cronuser /var/spool/cron/crontabs/cronuser && chmod 600 /var/spool/cron/crontabs/cronuser

# Create a wrapper script to run the cron job
RUN echo '#!/bin/sh' > /usr/local/bin/cron-wrapper && \
    echo 'while true; do' >> /usr/local/bin/cron-wrapper && \
    echo '  /home/cronuser/cf_ddns' >> /usr/local/bin/cron-wrapper && \
    echo '  sleep 600' >> /usr/local/bin/cron-wrapper && \
    echo 'done' >> /usr/local/bin/cron-wrapper && \
    chmod +x /usr/local/bin/cron-wrapper

USER cronuser

CMD ["/usr/local/bin/cron-wrapper"]