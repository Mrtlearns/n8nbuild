# Final stage starts from official n8n runners
FROM docker.io/n8nio/runners:latest

USER root

# Copy wheels from GitHub Actions cache or artifact
# this will be filled in by GH Actions
COPY wheelhouse /wheelhouse

# Install runtime dependencies required by some wheels
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     libjpeg62-turbo libpng16-16 zlib1g \
  && rm -rf /var/lib/apt/lists/*

# Install from prebuilt wheels only
RUN cd /opt/runners/task-runner-python \
     && pip install --no-index --find-links=/wheelhouse \
         opencv-python-headless \
         numpy \
         pandas \
         pillow \
         pypdf

# Copy your runners config
COPY n8n-task-runners.json /etc/n8n-task-runners.json

USER runner
