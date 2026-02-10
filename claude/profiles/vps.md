# Profile: VPS (Development/Staging)

This profile is for headless VPS environments used for development or staging.

## Environment Context

- Headless server (no GUI)
- SSH access only
- May have services running (Docker, databases)
- Git operations should be more careful

## Additional Caution

- Always check what's running before restarting services: `docker ps`, `systemctl status`
- Before modifying configs, check if services depend on them
- Prefer `docker-compose down` over `docker kill`

## Requires Approval

- Restarting or stopping any service
- Modifying systemd units
- Changing firewall rules
- Any `sudo` operation that modifies system state
