# Django Netmiko API

API for running read-only show commands against network devices via SSH (Netmiko).

## Setup

```bash
pip install -r requirements.txt
```

Set credentials via environment variables:

- `NET_DEVICE_USERNAME` (required)
- `NET_DEVICE_PASSWORD` (required)
- `NET_DEVICE_ENABLE_PASSWORD` (optional)
- `NET_DEVICE_PORT` (optional, default: 22)

## Start

```bash
export NET_DEVICE_USERNAME=your_username
export NET_DEVICE_PASSWORD=your_password
./scripts/start.sh
```

Runs at `http://localhost:8000`. The script kills any existing process on port 8000 before starting.

## API

**GET** `/api/v1/health`

Health check endpoint for load balancers and monitoring.

```bash
curl http://localhost:8000/api/v1/health
```

Response:
```json
{"status": "ok", "timestamp": "2025-02-18T12:00:00.000000Z"}
```

---

**POST** `/api/v1/run-show`

```bash
curl -X POST -u admin:admin http://host.docker.internal:8000/api/v1/run-show \
  -H "Content-Type: application/json" \
  -d '{"device_ip":"172.18.9.31","device_type":"arista_eos","command":"show version"}'
```

| Parameter     | Required | Description                               |
|--------------|----------|-------------------------------------------|
| `device_ip`  | Yes      | IP address of the network device          |
| `device_type`| Yes      | Netmiko device type (e.g. `arista_eos`, `cisco_ios`) |
| `command`    | Yes      | Show command to run (e.g. `show version`)  |

## Configuration

- **textfsm_templates**: Optional. Place under `textfsm_templates/<device_type>/<command>.tpl` for parsed output.

## Docker

n8n_engine and netdevops run on **separate networks**:

| Service    | Container   | Port | Network        |
|------------|-------------|------|----------------|
| n8n_engine | n8n_engine   | 5678 | n8n_network    |
| netdevops  | netdevops    | 8000 | netdevops_network |

**n8n HTTP Request URL:** `http://host.docker.internal:8000/api/v1/run-show`

```bash
# Fresh rebuild (removes old images, builds from scratch)
./scripts/docker-rebuild.sh
```
