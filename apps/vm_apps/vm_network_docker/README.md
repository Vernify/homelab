# Network Docker VM

This VM hosts network-related Docker containers including UniFi Network Application.

## Infrastructure

- **Proxmox Host**: pve08
- **VM ID**: 2205
- **IP Address**: 192.168.22.5
- **OS**: Ubuntu/Debian
- **Storage**: 
  - OS: Default disk
  - Docker data: `/dev/vdb` mounted at `/var/lib/docker`

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

All service configurations are managed by Ansible templates and stored in version control (repo). Only persistent data in Docker volumes needs backing up.

**Single backup requirement**:
```bash
# Backup Docker volumes (contains all service data)
sudo tar czf /backup/network-docker-volumes-$(date +%Y%m%d).tar.gz -C /var/lib/docker volumes/
```

**Reprovisioning workflow**:
1. Restore Docker volumes from backup:
   ```bash
   sudo tar xzf /backup/network-docker-volumes-YYYYMMDD.tar.gz -C /var/lib/docker
   ```
2. Run Ansible playbook (redeploys all configs from templates):
   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/deploy.yml
   ```

This approach ensures:
- ✅ All configurations are version-controlled and reproducible
- ✅ Only large data volumes need backing up (PostgreSQL, MongoDB, UniFi data)
- ✅ No secrets or config files loose in backups
- ✅ Single restore point (volumes backup) covers all data

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

**Update UniFi**:
```bash
cd /opt/unifi
sudo docker compose pull
sudo docker compose up -d
```

**Backup UniFi data**:
```bash
# Data is in Docker volume: unifi_unifi-app
sudo docker run --rm -v unifi_unifi-app:/data -v $(pwd):/backup ubuntu tar czf /backup/unifi-backup-$(date +%Y%m%d).tar.gz /data
```

**Restore UniFi data**:
```bash
# Stop UniFi
cd /opt/unifi
sudo docker compose down

# Restore from backup
sudo docker run --rm -v unifi_unifi-app:/data -v $(pwd):/backup ubuntu tar xzf /backup/unifi-backup-YYYYMMDD.tar.gz -C /

# Start UniFi
sudo docker compose up -d
```
