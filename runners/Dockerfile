# v1.3 — Switch to n8n-supported dependency install (pnpm/uv); remove apt/apk OS installs that break when base image changes.

FROM n8nio/runners:latest

USER root

# --- JavaScript runner dependencies (Code node JS) ---
# n8n docs: extend runners by installing packages inside the task-runner-javascript directory
RUN cd /opt/runners/task-runner-javascript && pnpm add \
  pdf-lib \
  uuid \
  moment \
  sharp

# --- Python runner dependencies (Code node Python) ---
# n8n docs: install python packages inside task-runner-python directory via uv pip
RUN cd /opt/runners/task-runner-python && uv pip install \
  pypdf \
  pillow \
  numpy \
  pandas \
  opencv-python-headless

# Custom allowlist config (must be valid JSON)
COPY n8n-task-runners.json /etc/n8n-task-runners.json

USER runner
