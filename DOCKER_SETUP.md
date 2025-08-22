# Docker Setup Guide for MSSQL MCP Server

## Prerequisites

### 1. Install Docker Desktop for Windows
- Download from: https://www.docker.com/products/docker-desktop/
- System Requirements:
  - Windows 10 64-bit: Pro, Enterprise, or Education (Build 19041 or higher)
  - Windows 11 64-bit: Home, Pro, Enterprise, or Education
  - WSL 2 backend enabled (recommended)

### 2. Start Docker Desktop
1. Open Docker Desktop from Start Menu
2. Wait for Docker to fully initialize (whale icon appears in system tray)
3. Verify Docker is running:
   ```powershell
   docker --version
   ```

## Quick Start

### Option 1: Use PowerShell Build Script (Recommended)
```powershell
# Run the build script
.\build-docker.ps1
```

The script will:
- Check if Docker is running (and try to start it if not)
- Create .env file from template if missing
- Prompt you to set database credentials
- Build the Docker image
- Optionally start the container

### Option 2: Manual Setup

1. **Start Docker Desktop** (if not running):
   ```powershell
   # Check Docker status
   docker version
   
   # If not running, start Docker Desktop manually from Start Menu
   ```

2. **Configure Environment**:
   ```powershell
   # Copy environment template
   cp .env.production .env
   
   # Edit .env with your database credentials
   notepad .env
   ```

3. **Build and Run**:
   ```powershell
   # Build the Docker image
   docker-compose build
   
   # Start the container
   docker-compose up -d
   
   # View logs
   docker-compose logs -f
   ```

## Portainer Deployment

### Deploy Stack in Portainer

1. **Access Portainer**
2. Navigate to **Stacks** → **Add Stack**
3. **Name**: `mssql-mcp-server`
4. **Build method**: Choose one:
   - **Upload**: Upload the `docker-compose.yml` file
   - **Web editor**: Copy and paste the docker-compose.yml content
   - **Git Repository**: If your code is in Git

5. **Environment Variables** (in Portainer):
   ```
   DB_SERVER=your-sql-server-host
   DB_DATABASE=your-database
   DB_USER=your-username
   DB_PASSWORD=your-password
   ```

6. Click **Deploy the stack**

### Alternative: Pre-built Image

If you've pushed your image to a registry:

1. Update `docker-compose.yml`:
   ```yaml
   services:
     mssql-mcp-server:
       image: your-registry/mssql-mcp-server:latest
       # Remove the 'build: .' line
   ```

2. Deploy in Portainer as above

## Access Points

Once running, access the server at:

- **Status Page**: http://your-host:8585/
- **SSE Endpoint**: http://your-host:8585/sse
- **Diagnostic**: http://your-host:8585/diagnostic
- **Tools List**: http://your-host:8585/tools
- **Messages**: http://your-host:8585/messages (POST)

## Troubleshooting

### Docker Not Running
```powershell
# Windows (PowerShell as Administrator)
Start-Service docker

# Or start Docker Desktop from Start Menu
```

### Port Already in Use
```powershell
# Check what's using port 8585
netstat -ano | findstr :8585

# Change port in docker-compose.yml if needed
```

### Database Connection Issues
- Ensure SQL Server allows remote connections
- Check firewall rules for port 1433
- For local SQL Server, use `host.docker.internal` as DB_SERVER
- Verify credentials in .env file

### View Container Logs
```powershell
# Live logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100
```

### Restart Container
```powershell
docker-compose restart
```

### Stop and Remove Container
```powershell
docker-compose down

# With volumes
docker-compose down -v
```

## Health Check

The container includes a health check that runs every 30 seconds:
```powershell
# Check container health
docker ps
docker inspect mssql-mcp-server --format='{{.State.Health.Status}}'
```

## Volume Mounts

The following directories are mounted as volumes:
- `./query_results`: Stores query result files
- `./logs`: Application logs

These persist data between container restarts.