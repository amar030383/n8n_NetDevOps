# NetDevOps API

REST API for running show commands on network devices via SSH (Netmiko). Designed to integrate with n8n for network automation workflows.

## Architecture

```
n8n_engine (5678)  -->  netdevops API (8000)  -->  Network Devices (SSH)
```

Both services run as separate Docker containers on isolated networks. n8n reaches the API via `http://host.docker.internal:8000`.

## Quick Start

```bash
cp .env.example .env
docker compose up -d
```

- **n8n UI:** http://localhost:5678
- **NetDevOps API:** http://localhost:8000

## API

### Health Check

```
GET /api/v1/health
```

```bash
curl http://localhost:8000/api/v1/health
```

### Run Show Command

```
POST /api/v1/run-show
```

Requires HTTP Basic Auth (`admin:admin` by default).

| Parameter         | Required | Description                                          |
|-------------------|----------|------------------------------------------------------|
| `device_ip`       | Yes      | IP address of the network device                     |
| `device_type`     | Yes      | Netmiko device type (`cisco_ios`, `arista_eos`, etc) |
| `command`         | Yes      | Show command to run                                  |
| `username`        | Yes      | SSH username for the device                          |
| `password`        | Yes      | SSH password for the device                          |
| `enable_password` | No       | Enable mode password                                 |
| `port`            | No       | SSH port (default: 22)                               |

```bash
curl -X POST -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{
    "device_ip": "10.0.0.1",
    "device_type": "cisco_ios",
    "command": "show version",
    "username": "admin",
    "password": "secret"
  }' \
  http://localhost:8000/api/v1/run-show
```

Output is automatically parsed via TextFSM (via Netmiko) when a matching template exists.

## n8n Integration

In your n8n HTTP Request node:

- **URL:** `http://host.docker.internal:8000/api/v1/run-show`
- **Method:** POST
- **Headers:** `authorization: Basic YWRtaW46YWRtaW4=`
- **Body:** JSON with `device_ip`, `device_type`, `command`, `username`, `password`

## Docker

| Container    | Port | Network           |
|-------------|------|-------------------|
| n8n_engine  | 5678 | n8n_network       |
| netdevops   | 8000 | netdevops_network |

```bash
docker compose up -d            # Start
docker compose down             # Stop
docker restart netdevops        # Restart API after code changes
./scripts/docker-rebuild.sh     # Full rebuild from scratch
```

## Local Development

```bash
pip install -r requirements.txt
./scripts/start.sh
```

## Project Structure

```
├── api/
│   ├── views.py                 # API endpoints
│   ├── urls.py                  # URL routing
│   └── services/
│       └── netmiko_service.py   # SSH connection logic
├── netapi/
│   ├── settings.py              # Django settings
│   ├── urls.py                  # Root URL config
│   └── wsgi.py                  # WSGI entry point
├── scripts/
│   ├── start.sh                 # Local dev startup
│   ├── docker-entrypoint.sh     # Container entrypoint
│   ├── docker-rebuild.sh        # Full Docker rebuild
│   └── create_admin.py          # Django admin user setup
├── docker-compose.yml
├── Dockerfile
└── requirements.txt
```
