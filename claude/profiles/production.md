# Profile: Production VPS

This profile is for production servers. MAXIMUM CAUTION.

## Environment Context

- Live production server
- Real users may be affected
- Downtime has consequences
- Changes should be minimal and reversible

## Elevated Restrictions

- NO direct database modifications without explicit approval
- NO service restarts without understanding impact
- NO git push to any branch without approval
- Always create backups before modifying data

## Requires Explicit Approval (restate command + wait)

- ANY write operation to databases
- ANY service restart or reload
- ANY file deletion (even logs)
- ANY config change
- Deployments of any kind

## Preferred Patterns

- Use blue-green deployments when available
- Prefer rollback over fix-forward
- Check monitoring/logs before and after changes
- Notify in team channel before significant changes
