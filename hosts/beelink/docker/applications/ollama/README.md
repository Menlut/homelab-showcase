# Ollama — Local AI

Local model-serving API for AI workloads.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- External network: `ai-services-network`.
- The shared network(s) must exist on the Docker host before deployment.
- API: `127.0.0.1:11434`, shared with approved containers on the AI network.
- Models and local state: `./data`.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `OLLAMA_KEEP_ALIVE` | How long an unused model remains loaded. |
| `OLLAMA_MAX_LOADED_MODELS` | Maximum models kept loaded simultaneously. |
| `OLLAMA_NUM_PARALLEL` | Maximum concurrent inference requests. |

## Setup and credentials

No password key is configured for the Ollama API in this stack; restrict access through the network/proxy. Adjust model limits in `.env` to suit the Beelink CPU.

## Deploy / check

```bash
cd /home/homelab/docker/applications/ollama
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
