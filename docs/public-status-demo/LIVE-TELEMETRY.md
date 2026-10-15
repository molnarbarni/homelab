# Live telemetry publisher

The GitHub Pages dashboard is static by design. This publisher allows the home server to send a **read-only snapshot** from Prometheus to the Pages deployment without opening Prometheus to the public internet and without committing metrics to Git history.

The page still shows synthetic demo data until the server-side publisher is installed and configured.

## Data flow

1. The server queries its private Prometheus API.
2. The script collects host CPU, memory, root filesystem, uptime, load, network rates, 24-hour resource history, and named Blackbox Exporter checks.
3. It sends the JSON snapshot to the repository's `pages-demo.yml` workflow using GitHub's `workflow_dispatch` API.
4. The workflow validates the snapshot age and schema, then deploys it as a Pages artifact. It does not commit the snapshot to the repository.
5. The public page shows the timestamp and marks telemetry stale if it is more than 20 minutes old.

Only metrics and the service names configured in the publisher are published. Do not add secrets, IP addresses, URLs, filesystem paths, or private application data to the snapshot.

## One-time setup on the server

### 1. Create a narrowly scoped token

Create a fine-grained personal access token in GitHub for **only** `molnarbarni/homelab`, with **Actions: Read and write** permission. No repository Contents permission is needed. Keep the token private; never commit it or paste it into chat.

### 2. Install the publisher script

Run on the server as `barni`:

```bash
mkdir -p /home/barni/.config
curl -fsSL https://raw.githubusercontent.com/molnarbarni/homelab/main/scripts/publish-dashboard-snapshot.py \
  -o /home/barni/homelab/scripts/publish-dashboard-snapshot.py
chmod 700 /home/barni/homelab/scripts/publish-dashboard-snapshot.py
```

### 3. Configure the local-only environment file

Create `/home/barni/.config/homelab-dashboard.env` with these two lines, replacing the token and confirming the current Prometheus address:

```bash
PROMETHEUS_URL=http://100.64.72.18:9090
GITHUB_TOKEN=github_pat_REPLACE_WITH_YOUR_TOKEN
```

Protect it:

```bash
chmod 600 /home/barni/.config/homelab-dashboard.env
```

The Prometheus address is private and should remain reachable only from the server/tailnet. Do **not** expose port 9090 to the public internet.

### 4. Install and start the timer

```bash
sudo install -m 0644 /home/barni/homelab/systemd/homelab-dashboard-publish.service /etc/systemd/system/
sudo install -m 0644 /home/barni/homelab/systemd/homelab-dashboard-publish.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now homelab-dashboard-publish.timer
sudo systemctl start homelab-dashboard-publish.service
```

Inspect the first run:

```bash
systemctl status homelab-dashboard-publish.service
journalctl -u homelab-dashboard-publish.service -n 50 --no-pager
systemctl list-timers homelab-dashboard-publish.timer
```

If publishing fails, the script exits non-zero and leaves the currently published snapshot untouched. Check the Prometheus API reachability, target labels, and token permissions before retrying.

## Limitations

- This is a periodic snapshot (15-minute publisher timer), not a live streaming feed.
- The dashboard is public; all metrics and service names included in the snapshot are public.
- The publisher only sends metrics if the Prometheus queries succeed and enough history is available.
- The GitHub token is stored locally in a mode-600 environment file and must not be committed.
