FROM python:3.11.12-bookworm

ARG PYTHON_VERSION="3.11.12"

WORKDIR /app

# Update debian
RUN apt-get update
RUN apt-get upgrade -y

# Setup UV
ENV PATH="/app/.venv/bin:$PATH" \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=python$PYTHON_VERSION \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/app/.venv

COPY --from=ghcr.io/astral-sh/uv:0.5.4 /uv /bin/uv

EXPOSE 8010

# Keep the container running
CMD uv sync && fastapi run main.py --port 8010
