#!/usr/bin/env python3
"""Publish a read-only Prometheus snapshot to the GitHub Pages dashboard.

The script never commits metrics to Git. It sends a compact, base64-encoded
snapshot to a workflow_dispatch input; the workflow validates it and deploys
the resulting static Pages artifact.
"""
from __future__ import annotations

import base64
import json
import os
import sys
from datetime import datetime, timedelta, timezone
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


REPOSITORY = "molnarbarni/homelab"
WORKFLOW = "pages-demo.yml"
STEP_SECONDS = 3600
HISTORY_HOURS = 24
SERVICE_NAMES = {
    "jellyfin": "Jellyfin",
    "opportunity-radar": "Opportunity Radar",
    "qbittorrent": "qBittorrent",
    "prowlarr": "Prowlarr",
    "seerr": "Seerr",
    "sonarr": "Sonarr",
    "radarr": "Radarr",
    "bazarr": "Bazarr",
}


class PublishError(RuntimeError):
    pass


def http_json(url: str, *, headers: dict[str, str] | None = None, body: bytes | None = None):
    request = Request(url, data=body, headers=headers or {}, method="POST" if body is not None else "GET")
    try:
        with urlopen(request, timeout=15) as response:
            raw = response.read()
    except (HTTPError, URLError, TimeoutError) as exc:
        detail = exc.read().decode("utf-8", "replace") if isinstance(exc, HTTPError) else str(exc)
        raise PublishError(f"HTTP request failed for {url}: {detail}") from exc
    if not raw:
        return None
    try:
        return json.loads(raw)
    except json.JSONDecodeError as exc:
        raise PublishError(f"Invalid JSON response from {url}") from exc


def prom_url(base: str, path: str, params: dict[str, str]) -> str:
    return f"{base.rstrip('/')}/api/v1/{path}?{urlencode(params)}"


def query_result(base: str, expression: str) -> list[dict]:
    payload = http_json(prom_url(base, "query", {"query": expression}))
    if not isinstance(payload, dict) or payload.get("status") != "success":
        raise PublishError(f"Prometheus query failed: {expression}")
    result = payload.get("data", {}).get("result", [])
    if not result:
        raise PublishError(f"Prometheus returned no data for query: {expression}")
    return result


def query_scalar(base: str, expression: str) -> float:
    result = query_result(base, expression)
    for series in result:
        values = series.get("value")
        if values and len(values) > 1:
            try:
                value = float(values[1])
                if value == value and abs(value) != float("inf"):
                    return value
            except (TypeError, ValueError):
                continue
    raise PublishError(f"Prometheus query returned no numeric value: {expression}")


def query_range(base: str, expression: str, start: datetime, end: datetime) -> dict[int, float]:
    params = {
        "query": expression,
        "start": str(start.timestamp()),
        "end": str(end.timestamp()),
        "step": str(STEP_SECONDS),
    }
    payload = http_json(prom_url(base, "query_range", params))
    if not isinstance(payload, dict) or payload.get("status") != "success":
        raise PublishError(f"Prometheus range query failed: {expression}")
    result = payload.get("data", {}).get("result", [])
    if not result:
        raise PublishError(f"Prometheus returned no history for query: {expression}")
    points: dict[int, float] = {}
    for series in result:
        for timestamp, raw_value in series.get("values", []):
            try:
                value = float(raw_value)
                if value == value and abs(value) != float("inf"):
                    points[int(round(float(timestamp)))] = value
            except (TypeError, ValueError):
                continue
    if not points:
        raise PublishError(f"Prometheus history has no numeric points: {expression}")
    return points


def main() -> int:
    prometheus = os.environ.get("PROMETHEUS_URL", "").strip()
    token = os.environ.get("GITHUB_TOKEN", "").strip()
    if not prometheus:
        raise PublishError("PROMETHEUS_URL is missing from the service environment.")
    if not token:
        raise PublishError("GITHUB_TOKEN is missing; use a fine-grained token with Actions: write on this repo.")

    now = datetime.now(timezone.utc).replace(microsecond=0)
    start = now - timedelta(hours=HISTORY_HOURS)
    cpu_expr = '100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])))'
    memory_expr = '100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)'
    disk_filter = '{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"}'
    disk_expr = f'100 * (1 - node_filesystem_avail_bytes{disk_filter} / node_filesystem_size_bytes{disk_filter})'

    cpu = query_scalar(prometheus, cpu_expr)
    memory = query_scalar(prometheus, memory_expr)
    disk = query_scalar(prometheus, disk_expr)
    uptime = query_scalar(prometheus, "node_time_seconds - node_boot_time_seconds")
    load = query_scalar(prometheus, "node_load1")
    memory_available = query_scalar(prometheus, "node_memory_MemAvailable_bytes / 1073741824")
    memory_total = query_scalar(prometheus, "node_memory_MemTotal_bytes / 1073741824")
    disk_available = query_scalar(prometheus, f"node_filesystem_avail_bytes{disk_filter} / 1073741824")
    disk_total = query_scalar(prometheus, f"node_filesystem_size_bytes{disk_filter} / 1073741824")
    network_rx = query_scalar(prometheus, 'sum(rate(node_network_receive_bytes_total{device!~"lo|docker.*|br.*|veth.*|tailscale.*"}[5m])) * 8 / 1000000')
    network_tx = query_scalar(prometheus, 'sum(rate(node_network_transmit_bytes_total{device!~"lo|docker.*|br.*|veth.*|tailscale.*"}[5m])) * 8 / 1000000')

    cpu_history = query_range(prometheus, cpu_expr, start, now)
    memory_history = query_range(prometheus, memory_expr, start, now)
    disk_history = query_range(prometheus, disk_expr, start, now)
    history = []
    for timestamp in sorted(set(cpu_history) & set(memory_history) & set(disk_history)):
        history.append({
            "t": timestamp * 1000,
            "c": round(cpu_history[timestamp], 2),
            "m": round(memory_history[timestamp], 2),
            "d": round(disk_history[timestamp], 2),
        })
    if len(history) < 2:
        raise PublishError("Prometheus returned fewer than two aligned history points; refusing to publish incomplete history.")

    service_series = query_result(prometheus, 'probe_success{job="blackbox-http"}')
    services = []
    for series in service_series:
        target = series.get("metric", {}).get("target_name")
        values = series.get("value")
        if not target or not values or target not in SERVICE_NAMES:
            continue
        try:
            up = float(values[1]) == 1.0
        except (TypeError, ValueError):
            continue
        services.append({
            "name": SERVICE_NAMES[target],
            "up": up,
            "passing": 1 if up else 0,
            "total": 1,
        })
    if not services:
        raise PublishError('No named services found for Prometheus query probe_success{job="blackbox-http"}.')

    snapshot = {
        "schema": 1,
        "mode": "live",
        "generated_at": now.isoformat().replace("+00:00", "Z"),
        "current": {
            "cpu": round(max(0.0, min(100.0, cpu)), 1),
            "memory": round(max(0.0, min(100.0, memory)), 1),
            "disk": round(max(0.0, min(100.0, disk)), 1),
            "uptime": max(0, int(uptime)),
            "load": round(max(0.0, load), 2),
            "memory_used_gb": round(max(0.0, memory_total - memory_available), 2),
            "memory_available_gb": round(max(0.0, memory_available), 2),
            "memory_total_gb": round(max(0.0, memory_total), 2),
            "disk_used_gb": round(max(0.0, disk_total - disk_available), 1),
            "disk_available_gb": round(max(0.0, disk_available), 1),
            "disk_total_gb": round(max(0.0, disk_total), 1),
            "network_rx_mbps": round(max(0.0, network_rx), 3),
            "network_tx_mbps": round(max(0.0, network_tx), 3),
        },
        "history": history,
        "services": sorted(services, key=lambda item: item["name"].lower()),
    }

    encoded = base64.b64encode(json.dumps(snapshot, separators=(",", ":")).encode("utf-8")).decode("ascii")
    if len(encoded) > 60000:
        raise PublishError("Snapshot is too large for the workflow input; refusing to send it.")

    url = f"https://api.github.com/repos/{REPOSITORY}/actions/workflows/{WORKFLOW}/dispatches"
    body = json.dumps({"ref": "main", "inputs": {"snapshot": encoded}}).encode("utf-8")
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
        "Content-Type": "application/json",
        "User-Agent": "homelab-public-dashboard-publisher",
    }
    http_json(url, headers=headers, body=body)
    print(f"Dispatched live dashboard snapshot: {snapshot['generated_at']}; "
          f"{len(history)} history points; {len(services)} service checks.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except PublishError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
