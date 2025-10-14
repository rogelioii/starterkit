# Starterkit Docker Setup

This directory contains the Docker configuration for the starterkit development environment.

## Docker Compose Setup

The `docker-compose.yml` file runs your starterkit container alongside a PostgreSQL database.

### Services

#### starterkit
- **Image**: Built from `Dockerfile`
- **Container**: `starterkit`
- **Features**: 
  - All tools (Terraform, kubectl, kubeseal, AWS CLI, Docker)
  - Volume mounted workspace
  - Docker socket access for Docker-in-Docker
  - PostgreSQL connection environment variables

#### postgres
- **Image**: `postgres:15-alpine` (lightweight PostgreSQL 15)
- **Container**: `starterkit-postgres`
- **Port**: `5432` (exposed to host)
- **Database**: `starterkit`
- **User**: `starterkit`
- **Password**: `starterkit123`

### Usage

#### Start services
```bash
docker-compose up -d
```

#### Access starterkit container
```bash
docker-compose exec starterkit bash
```

#### Access PostgreSQL
```bash
# From host
psql -h localhost -p 5432 -U starterkit -d starterkit

# From starterkit container
psql -h postgres -p 5432 -U starterkit -d starterkit
```

#### Stop services
```bash
docker-compose down
```

#### Stop and remove volumes
```bash
docker-compose down -v
```

### Environment Variables

The starterkit container has these PostgreSQL connection variables:
- `POSTGRES_HOST=postgres`
- `POSTGRES_PORT=5432`
- `POSTGRES_DB=starterkit`
- `POSTGRES_USER=starterkit`
- `POSTGRES_PASSWORD=starterkit123`

### Volumes

- **Workspace**: `../` → `/workspace` (your project files)
- **Docker Socket**: `/var/run/docker.sock` (for Docker-in-Docker)
- **PostgreSQL Data**: `postgres_data` (persistent database storage)
- **Init Scripts**: `../init-scripts` → `/docker-entrypoint-initdb.d` (optional SQL scripts)

### Network

Both services run on the `starterkit-network` bridge network, allowing them to communicate using service names as hostnames.


## Manual Docker Build

### Build
```bash
docker build -t starterkit . --no-cache
docker tag starterkit 192.168.2.207:18079/starterkit:latest
docker push 192.168.2.207:18079/starterkit:latest
```

### Security Scan
```bash
docker scout quickview
docker scout cves local://starterkit:latest
```