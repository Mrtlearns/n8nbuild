# v1.0 — Always extend upstream runners:latest and add pdf-lib
FROM n8nio/runners:latest

USER root
RUN cd /opt/runners/task-runner-javascript && pnpm add pdf-lib
COPY n8n-task-runners.json /etc/n8n-task-runners.json
USER runner
