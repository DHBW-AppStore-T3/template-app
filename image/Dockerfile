# The template app as a pod: a static site served by unprivileged nginx. The
# platform runs it non-root with a read-only root filesystem (appstore.yaml).
FROM docker.io/nginxinc/nginx-unprivileged:1.30-alpine
# Alpine security fixes that the upstream image does not have yet, at every CI build: app-ci.yml sets SECURITY_REFRESH
# to a new value for each run, so the build cache cannot keep an older package state (app-registry README,
# "Sicherheitsupdates im Image"). Root for this build step only; the image returns to upstream's unprivileged user 101
# right after.
USER root
ARG SECURITY_REFRESH
RUN apk upgrade --no-cache
USER 101
COPY nginx.conf /etc/nginx/nginx.conf
COPY site/ /usr/share/nginx/html/
