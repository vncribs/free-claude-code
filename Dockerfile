FROM python:3.14.10-slim

WORKDIR /app

RUN pip install uv

COPY . .

RUN uv sync --locked --no-dev

CMD ["uv", "run", "--no-sync", "fcc-server"]
