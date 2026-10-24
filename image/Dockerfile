# The template app as a pod: a static site served by unprivileged nginx. The
# platform runs it non-root with a read-only root filesystem (appstore.yaml).
FROM docker.io/nginxinc/nginx-unprivileged:1.30-alpine
# Alpine security fixes that the upstream image does not have yet (Trivy: brotli-libs). Root for this build step
# only; the image returns to upstream's unprivileged user 101 right after.
USER root
RUN apk upgrade --no-cache
USER 101
COPY nginx.conf /etc/nginx/nginx.conf
COPY site/ /usr/share/nginx/html/
