# Stage: Builder with full build tools
FROM python:3.13-slim-bullseye AS builder

WORKDIR /wheels

# Install build dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     build-essential cmake pkg-config \
     libjpeg-dev libpng-dev zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

# Upgrade pip tools
RUN pip install --upgrade pip setuptools wheel

# Copy dependency list
COPY requirements-wheels.txt .

# Generate wheels
RUN pip wheel --wheel-dir /wheels -r requirements-wheels.txt

# Create metadata with the python ABI for reuse detection
RUN python - << 'EOF' > /wheels/metadata.json
import sysconfig, json
meta = {
  "python_abi": sysconfig.get_config_var("SOABI"),
  "platform_tag": sysconfig.get_platform(),
}
print(json.dumps(meta))
EOF

