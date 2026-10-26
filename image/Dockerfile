# The template app as a pod: a static site served by unprivileged nginx. The
# platform runs it non-root with a read-only root filesystem (appstore.yaml).
FROM docker.io/nginxinc/nginx-unprivileged:1.30-alpine
# Alpine security fixes that the upstream image does not have yet (Trivy: brotli-libs; curl/libcurl CVE-2026-92392,
# fixed in 8.23.0-r0). The minimum versions fail the build instead of shipping without a fix; edit this line for the
# next one, since an unchanged line lets the build cache reuse the old layer. Root for this build step only; the
# image returns to upstream's unprivileged user 101 right after.
USER root
RUN apk upgrade --no-cache && apk add --no-cache "curl>=8.23.0-r0" "libcurl>=8.23.0-r0"
USER 101
COPY nginx.conf /etc/nginx/nginx.conf
COPY site/ /usr/share/nginx/html/
