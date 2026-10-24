#!/usr/bin/env bash
# Smoke test of the template image in the platform's security context (run by the central pipeline, see
# DHBW-AppStore-T3/app-registry templates/smoke-test-example.sh). IMAGE and PLATFORM_RUN_FLAGS come from the pipeline.
set -euo pipefail

# nginx writes only to /tmp (see image/nginx.conf), the one writable path in appstore.yaml.
# shellcheck disable=SC2086  # PLATFORM_RUN_FLAGS is meant to split into words
docker run -d --name smoke $PLATFORM_RUN_FLAGS --tmpfs /tmp "$IMAGE"

ok=0
for _ in $(seq 1 30); do
  # The cluster is IPv6-primary: the page must be served on [::1].
  if curl -fsS -o /dev/null "http://[::1]:8080/"; then ok=1; break; fi
  sleep 1
done
docker logs smoke
[ "$ok" = 1 ]

curl -fsS "http://[::1]:8080/" | grep -qi "<html"
