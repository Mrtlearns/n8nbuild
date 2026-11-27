# ghcr.io/mrtlearns/n8n-runners-pdflib:<N8N_VERSION>
# n8n external task runners (n8nio/runners) + pdf-lib for JS Code nodes and PDF/OCR tooling.
#
# N8N_VERSION must equal the version of the n8n main/worker containers that use these runners.
# Bump it TOGETHER with the n8n main/worker image pin (see README). CI reads the default below.
ARG N8N_VERSION=2.49.7

# n8nio/runners (2.49.x) ships WITHOUT the apk binary (the apk db + repositories are kept),
# so borrow apk.static from alpine for one layer and delete it again.
FROM docker.io/library/alpine:3.24 AS apktools
RUN apk add --no-cache apk-tools-static

FROM docker.io/n8nio/runners:${N8N_VERSION}
ARG N8N_VERSION
USER root
COPY --from=apktools /sbin/apk.static /tmp/apk.static
RUN set -eux; /tmp/apk.static --no-cache add qpdf ghostscript imagemagick tesseract-ocr unpaper; rm -f /tmp/apk.static
RUN cd /opt/runners/task-runner-javascript && pnpm add pdf-lib @pdf-lib/fontkit uuid date-fns lodash axios
RUN cd /opt/runners/task-runner-python && uv pip install pypdf pikepdf requests beautifulsoup4 pydantic ocrmypdf
# Runner launcher config = upstream default for this n8n version (keeps its hardening args)
# + site allowlist: JS external "pdf-lib", builtin "crypto"; Python stdlib "json", no external modules.
COPY n8n-task-runners.json /etc/n8n-task-runners.json
RUN chown root:root /etc/n8n-task-runners.json && chmod 644 /etc/n8n-task-runners.json
USER runner
LABEL org.opencontainers.image.version="${N8N_VERSION}" \
      org.opencontainers.image.title="n8n task runners + pdf-lib/pypdf (mrtlearns)" \
      org.opencontainers.image.source="https://github.com/Mrtlearns/n8nbuild"
