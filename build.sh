docker build --no-cache \
  --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"\
  --build-arg REVISION="$(git rev-parse HEAD)" \
  -t wickedbyte/docker-laravel:latest .
