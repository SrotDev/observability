Observability & Monitoring Stack (Local)

This repo provides a lightweight local observability setup using Docker Compose:

- Prometheus for scraping metrics and evaluating alert rules
- Node Exporter for system metrics
- Grafana for visualization (pre-provisioned with a dashboard and Prometheus datasource)
- Demo app (Flask) exposing `/metrics` with mock response-time and health metrics
- Bonus script `alert_dispatcher.sh` to fetch and log firing alerts

Prereqs
- Docker Desktop (with Compose v2)
- Optional: Git Bash/WSL for running the bash script on Windows

Quick Start (PowerShell)
```powershell
docker compose pull
docker compose build
docker compose up -d
```

Services
- App: http://localhost:8000 (endpoints: `/`, `/metrics`, `/healthz`)
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)

Prometheus
- Config: `prometheus.yml`
- Rules: `alert.rules.yml`
	- HighCPUUsage: CPU > 70% for 2m (from node-exporter)
	- AppDown: `up{job="app"} == 0` for 1m

Grafana
- Datasource: auto-provisioned (Prometheus)
- Dashboard: auto-imported from `grafana/dashboards/grafana-dashboard.json`
	- Panels: App Up, CPU Usage (%), App Response Time (ms), Memory Used (%)

Triggering Alerts (Examples)
- AppDown: `docker compose stop app`; wait 1+ minute; check Prometheus `Alerts` page or Grafana panel.
- HighCPUUsage: generate CPU load on the Docker host (or reduce threshold in `alert.rules.yml` temporarily). For a quick test, change `> 70` to `> 1`, then reload Prometheus: `Invoke-WebRequest -Method POST http://localhost:9090/-/reload` and observe the alert.

Bonus: Alert Dispatcher
Reads alerts from Prometheus API and writes to `alerts.log`.
```bash
chmod +x alert_dispatcher.sh
./alert_dispatcher.sh
```
Environment variables:
- `PROM_URL` (default `http://localhost:9090`)
- `LOG_FILE` (default `alerts.log`)

Screenshot (MUST)
- Please capture Grafana after metrics populate (30-60s) showing a panel with data and, ideally, a triggered alert.
- Save the image to `docs/grafana-screenshot.png` (create the `docs/` folder if missing).

Tear Down
```powershell
docker compose down
```

Tree
```
docker-compose.yml
prometheus.yml
alert.rules.yml
grafana/
	provisioning/
		datasources/datasource.yml
		dashboards/dashboard.yml
	dashboards/grafana-dashboard.json
app/
	Dockerfile
	requirements.txt
	app.py
alert_dispatcher.sh
docs/
	grafana-screenshot.png (to be added by you)
```