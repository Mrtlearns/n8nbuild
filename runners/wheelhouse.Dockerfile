# v1.0
# Summary: Build a wheelhouse image (no dependency on WHEELHOUSE_IMAGE). Produces /wheelhouse/*.whl for later injection.
# syntax=docker/dockerfile:1.7

FROM docker.io/n8nio/runners:latest AS builder

# Install build tooling (musl/alpine case) so heavy deps can compile if wheels aren't available
# NOTE: adjust package manager depending on base; n8nio/runners is currently alpine-based in your logs.
RUN apk add --no-cache \
    build-base \
    cmake \
    ninja \
    linux-headers \
    python3-dev \
    musl-dev \
    libffi-dev \
    openssl-dev \
    jpeg-dev \
    zlib-dev

WORKDIR /tmp/wheels

# Your wheel requirements list (you already reference this in workflow)
COPY runners/requirements-wheels.txt /tmp/requirements-wheels.txt

# Build wheels into /wheelhouse
RUN /opt/runners/task-runner-python/.venv/bin/pip wheel --no-cache-dir \
      -r /tmp/requirements-wheels.txt \
      -w /wheelhouse

# Final image just contains wheel artifacts
FROM scratch AS wheelhouse
COPY --from=builder /wheelhouse /wheelhouse
