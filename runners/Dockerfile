# v1.0
# Summary: Final runners image: stays on n8nio/runners:latest but injects prebuilt wheels from a wheelhouse image.
# syntax=docker/dockerfile:1.7

ARG WHEELHOUSE_IMAGE
FROM ${WHEELHOUSE_IMAGE} AS wheels

FROM docker.io/n8nio/runners:latest

# Copy wheels in
COPY --from=wheels /wheelhouse /tmp/wheelhouse

# Install wheels into the runner venv (no compiling here)
RUN cd /opt/runners/task-runner-python && \
    /opt/runners/task-runner-python/.venv/bin/pip install --no-cache-dir --no-index \
      --find-links=/tmp/wheelhouse \
      -r /opt/runners/task-runner-python/requirements.txt || true

# Install your additional packages strictly from wheelhouse
# (keep this list aligned with your allowlist)
RUN /opt/runners/task-runner-python/.venv/bin/pip install --no-cache-dir --no-index \
      --find-links=/tmp/wheelhouse \
      pypdf pillow numpy pandas opencv-python-headless

# Your runner config
COPY runners/n8n-task-runners.json /etc/n8n-task-runners.json
