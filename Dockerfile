
FROM python:3.14.10-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8000

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs npm git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

WORKDIR /app

RUN mkdir -p /app/agent_workspace/plans
ENV CLAUDE_WORKSPACE=/app/agent_workspace

RUN pip install uv

COPY . .

RUN SETUPTOOLS_SCM_PRETEND_VERSION=0.0.0 uv sync --locked --no-dev

COPY docker-entrypoint.sh /usr/local/bin/fcc-entrypoint
RUN chmod 755 /usr/local/bin/fcc-entrypoint

ENTRYPOINT ["/usr/local/bin/fcc-entrypoint"]
CMD ["uv", "run", "--no-sync", "fcc-server"]
