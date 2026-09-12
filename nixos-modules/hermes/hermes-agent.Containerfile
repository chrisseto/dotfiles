# vi: ft=dockerfile

FROM docker.io/nousresearch/hermes-agent:v2026.8.19

# https://hermes-agent.nousresearch.com/docs/user-guide/docker#durable-installs--build-a-derived-image

# Return to root for any modifications
USER root

# HACK: Permit unauthorized access. 
COPY dashboard-insecure.patch /tmp/dashboard-insecure.patch
RUN cd /opt/hermes && \
    git apply --check /tmp/dashboard-insecure.patch && \
    git apply /tmp/dashboard-insecure.patch && \
    cp /opt/hermes/docker/s6-rc.d/dashboard/run /etc/s6-overlay/s6-rc.d/dashboard/run && \
    grep -q "should_require_auth(host) and not allow_public" /opt/hermes/hermes_cli/web_server.py && \
    grep -q -- "--insecure" /etc/s6-overlay/s6-rc.d/dashboard/run && \
    rm -f /tmp/dashboard-insecure.patch


# Drop back to hermes for running.
USER hermes
