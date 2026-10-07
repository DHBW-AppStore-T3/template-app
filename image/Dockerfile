# The template app as a pod: a static site served by unprivileged nginx. The
# platform runs it non-root with a read-only root filesystem (appstore.yaml).
FROM docker.io/nginxinc/nginx-unprivileged:1.27-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY site/ /usr/share/nginx/html/
