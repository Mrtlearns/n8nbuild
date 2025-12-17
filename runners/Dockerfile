FROM n8nio/runners:latest

USER root

# --- OS packages for PDF/image/OCR toolbox ---
# (qpdf + ghostscript + imagemagick + tesseract + unpaper)
RUN set -eux; \
  if command -v apt-get >/dev/null 2>&1; then \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      qpdf ghostscript imagemagick tesseract-ocr unpaper; \
    rm -rf /var/lib/apt/lists/*; \
  elif command -v apk >/dev/null 2>&1; then \
    apk add --no-cache \
      qpdf ghostscript imagemagick tesseract-ocr unpaper; \
  else \
    echo "No supported package manager found (apt-get/apk)"; \
    exit 1; \
  fi

# --- JS runner deps ---
RUN cd /opt/runners/task-runner-javascript && pnpm add \
  pdf-lib @pdf-lib/fontkit uuid date-fns lodash axios

# --- Python runner deps ---
RUN cd /opt/runners/task-runner-python && uv pip install \
  pypdf pikepdf requests beautifulsoup4 pydantic ocrmypdf

# --- Launcher config (allowlist) ---
COPY n8n-task-runners.json /etc/n8n-task-runners.json

# Some setups need explicit perms for the runner user to read the file
RUN chown runner:runner /etc/n8n-task-runners.json && chmod 644 /etc/n8n-task-runners.json

USER runner
