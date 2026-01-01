# Network Docker VM

This VM hosts network-related Docker containers including UniFi Network Application and Netbox.

## Quick Start

```bash
# 1. Provision infrastructure with Terraform
cd terraform
terraform apply

# 2. Configure VM with Ansible (automatically restores from latest backup if fresh install)
cd ../ansible
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml
```

## Automated Rebuilds

The Ansible playbook is fully idempotent and rebuild-safe:

- **Fresh Install Detection**: Automatically detects if `/var/lib/docker/volumes` is empty
- **Auto-Restore**: If backups exist and volumes are empty, restores latest backup automatically
- **Non-Destructive**: Never overwrites existing data - safe to run on production systems
- **NFS Mount**: Backup share mounted early in playbook for restore availability

To disable auto-restore, set in `defaults/main.yml`:
```yaml
vm_network_docker_auto_restore: false
```
## Services

### UniFi Network Application
- **Compose Location**: `/opt/unifi/docker-compose.yml`
- **Data Volumes**: 
  - `unifi_unifi-app` → `/config` (UniFi configuration and data)
  - `unifi_unifi-db` → `/data/db` (MongoDB database)
- **Web UI**: https://192.168.22.5:8443
- **Inform URL**: http://192.168.22.5:8080/inform
- **Persistent Data**: ✅ All data in named volumes on `/dev/vdb`

### Netbox
- **Compose Location**: `/opt/netbox/docker-compose.yml`
- **Data Volumes**:
  - `netbox_netbox-postgres-data` → PostgreSQL database
  - `netbox_netbox-redis-data` → Redis cache
  - `netbox_netbox-redis-cache-data` → Redis cache
  - `netbox_netbox-media-files` → Uploaded media
  - `netbox_netbox-reports-files` → Custom reports
  - `netbox_netbox-scripts-files` → Custom scripts
- **Bind Mounts**:
  - `/opt/netbox/configuration` → `/etc/netbox/config` (read-only config)
- **Persistent Data**: ✅ All data in named volumes on `/dev/vdb`

### Twingate Connector
- **Container Name**: `twingate-tungsten-skunk`
- **Image**: `twingate/connector:1`
- **Persistent Data**: ❌ None required (stateless connector)

## Data Persistence

All persistent container data is stored in Docker named volumes on the dedicated disk (`/dev/vdb` mounted at `/var/lib/docker`):

```
/dev/vdb → /var/lib/docker/volumes/
  ├── unifi_unifi-app/          # UniFi configuration & backups
  ├── unifi_unifi-db/           # MongoDB database
  ├── netbox_netbox-postgres-data/  # Netbox database
  ├── netbox_netbox-media-files/    # Netbox media uploads
  ├── netbox_netbox-reports-files/  # Netbox reports
  ├── netbox_netbox-scripts-files/  # Netbox scripts
  ├── netbox_netbox-redis-data/     # Redis persistence
  └── netbox_netbox-redis-cache-data/ # Redis cache
```

**Reprovisioning Strategy**: 

All service configurations are managed by Ansible templates. Backups are automated via NFS mount to backup server. Rebuilds are fully automated.

**Automated Backup System**:
```bash
# Run backup (deployed by Ansible at /usr/local/bin/network-docker-backup.sh)
sudo network-docker-backup.sh

# Backups stored at: /backup/servers/$(hostname)/network-docker-*.tar.gz
# Retention: Last 3 days (automatic cleanup after successful backup)
```

**Automated Rebuild Process**:
1. Provision fresh VM with Terraform
2. Run Ansible playbook - it will:
   - Mount NFS backup share
   - Detect fresh install (no Docker volumes)
   - Automatically restore latest backup
   - Deploy all configurations
   - Start services

```bash
terraform apply
cd ../ansible
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml
# System fully restored and operational!
```

**Manual Restore** (if needed):
```bash
# Interactive mode (lists available backups)
sudo network-docker-restore.sh

# Or specify backup file directly
sudo network-docker-restore.sh /backup/servers/network-docker/network-docker-network-docker-20260101_120000.tar.gz
```

**What's backed up**:
- ✅ All Docker volumes (UniFi, Netbox databases, media, configs)
- ✅ Container states and network information
- ✅ Compose files and configurations

**Benefits**:
- ✅ All configurations are version-controlled and reproducible
- ✅ Automated backups to NFS server with retention
- ✅ Fully automated rebuild process (no manual restore needed)
- ✅ Idempotent - safe to run on existing systems
- ✅ Zero-touch disaster recovery
- ✅ Complete system state captured in each backup
- ✅ Simple one-command restore process

## Deployment

1. **Terraform**: Provision the VM and attach storage
   ```bash
   cd terraform
   terraform plan
   terraform apply
   ```

2. **Ansible**: Configure VM, migrate Docker data, deploy services
   ```bash
   cd ansible
   ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml
   ```

## Troubleshooting

### UniFi Device Adoption Issues

If devices show "Unable to resolve" or have malformed inform URLs after controller migration:

1. **Check device status**:
   ```bash
   # For switches
   ssh admin@<device-ip> 'mca-cli-op info' | grep -i status
   
   # For APs (some models use 'info' without mca-cli-op)
   ssh admin@<device-ip> 'info' | grep -i inform
   ```

2. **Set correct inform URL**:
   ```bash
   ssh admin@<device-ip> 'mca-cli-op set-inform http://192.168.22.5:8080/inform'
   ```

3. **Verify connection**:
   ```bash
   ssh admin@<device-ip> 'mca-cli-op info' | grep -i status
   # Should show: Status: Connected (http://192.168.22.5:8080/inform)
   ```

### UniFi Controller Issues

**Check system_ip configuration**:
```bash
sudo docker exec unifi-network-application cat /config/data/system.properties | grep system_ip
# Should show: system_ip=192.168.22.5
```

**View controller logs**:
```bash
sudo docker logs unifi-network-application --tail 100
```

**Restart UniFi container**:
```bash
cd /opt/unifi
sudo docker compose restart unifi-network-application
```

### Docker Data Migration

The Ansible playbook automatically migrates Docker data to a dedicated disk. To check migration status:

```bash
# Check if docker data is on dedicated disk
df -h | grep docker
# Should show: /dev/vdb mounted at /var/lib/docker

# Check old data backup
ls -la /var/lib/docker.old
```

## Maintenance

### Backups

**Run manual backup**:
```bash
sudo network-docker-backup.sh
```

**List available backups**:
```bash
ls -lh /backup/servers/$(hostname)/
```

**Restore from backup**:
```bash
# Interactive mode
sudo network-docker-restore.sh

# Or use latest backup directly
sudo network-docker-restore.sh latest
```

**Backup details**:
- Location: `/backup/servers/$(hostname)/` (NFS mount from 192.168.50.211)
- Retention: 3 days (automatic cleanup)
- Contents: Docker volumes, container states, compose files
- Log: `/var/log/network-docker-backup.log`

### Service Updates

**Update UniFi**:
```bash
cd /opt/unifi
sudo docker compose pull
sudo docker compose up -d
```

**Update Netbox**:
```bash
cd /opt/netbox
sudo docker compose pull
sudo docker compose up -d
```

**Update all services**:
```bash
# Re-run Ansible playbook to update configs and restart services
cd ansible
ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml
```
