# Used for opensips-telco only
#

FROM opensips/opensips

RUN apt-get update && apt-get install -y jq netcat-openbsd && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY src/opensips/opensips.cfg /etc/opensips/opensips.cfg
