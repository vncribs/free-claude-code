FROM python:3.14.10-slim

WORKDIR /app

RUN pip install uv

COPY . .

RUN SETUPTOOLS_SCM_PRETEND_VERSION=0.0.0 uv sync --locked --no-dev

CMD ["uv", "run", "--no-sync", "fcc-server"]
