# =========================
# FILE: runners/wheelhouse.Dockerfile
# =========================
# syntax=docker/dockerfile:1.7
FROM docker.io/n8nio/runners:latest AS build

USER root

# Build toolchain for Alpine/musl (required when opencv wheels are not available)
RUN apk add --no-cache \
    build-base \
    cmake \
    ninja \
    pkgconf \
    python3-dev \
    musl-dev \
    linux-headers \
    jpeg-dev \
    zlib-dev \
    libpng-dev \
    tiff-dev

WORKDIR /opt/runners/task-runner-python

# Only rebuild wheels if requirements-wheels.txt changes (good caching behavior)
COPY runners/requirements-wheels.txt /tmp/requirements-wheels.txt

# Build wheels into /wheelhouse (do NOT install into venv here)
RUN mkdir -p /wheelhouse \
 && uv pip install --upgrade pip setuptools wheel \
 && uv pip wheel --wheel-dir /wheelhouse -r /tmp/requirements-wheels.txt \
 && cp /tmp/requirements-wheels.txt /wheelhouse/requirements-wheels.txt

# Minimal runtime image that just carries the wheelhouse as an OCI artifact container
FROM alpine:3.20
COPY --from=build /wheelhouse /wheelhouse


# =========================
# FILE: runners/Dockerfile
# =========================
# syntax=docker/dockerfile:1.7
ARG WHEELHOUSE_IMAGE=ghcr.io/mrtlearns/n8n-runner-wheelhouse:latest
FROM ${WHEELHOUSE_IMAGE} AS wheels

FROM docker.io/n8nio/runners:latest

USER root

# Runtime tools you wanted (adjust packages as needed)
RUN apk add --no-cache \
    qpdf \
    ghostscript \
    imagemagick \
    tesseract-ocr \
    tesseract-ocr-data-eng \
    unpaper \
    libjpeg-turbo \
    zlib \
    libpng \
    tiff

COPY --from=wheels /wheelhouse /wheelhouse

# Install Python packages from wheelhouse only (no build during final image)
RUN cd /opt/runners/task-runner-python \
 && uv pip install --no-index --find-links=/wheelhouse -r /wheelhouse/requirements-wheels.txt

# Runner config
COPY runners/n8n-task-runners.json /etc/n8n-task-runners.json

USER runner
