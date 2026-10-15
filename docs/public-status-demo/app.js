const $ = id => document.getElementById(id);
let resourceChart;

function setMetric(id, barId, value, noteId, suffix = '%', validNote = 'Latest sample') {
  const valid = Number.isFinite(value);
  $(id).textContent = valid ? (suffix === '%' ? value.toFixed(1) : value) : '—';
  $(barId).style.width = valid ? `${Math.max(0, Math.min(100, value))}%` : '0%';
  if (noteId) $(noteId).textContent = valid ? validNote : 'No data';
}

function duration(seconds) {
  if (!Number.isFinite(seconds) || seconds < 0) return '—';
  const d = Math.floor(seconds / 86400);
  const h = Math.floor(seconds % 86400 / 3600);
  const m = Math.floor(seconds % 3600 / 60);
  return d ? `${d}d ${h}h` : `${h}h ${m}m`;
}

function renderChart(history) {
  const points = Array.isArray(history) ? history : [];
  const labels = points.map(p => new Date(p.t).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}));
  if (resourceChart) resourceChart.destroy();
  resourceChart = new Chart($('resource-chart'), {
    type:'line',
    data:{labels,datasets:[
      {label:'CPU',data:points.map(p=>p.c),borderColor:'#53d6e9',backgroundColor:'#53d6e91b',fill:true,tension:.35,pointRadius:0,borderWidth:2,spanGaps:true},
      {label:'Memory',data:points.map(p=>p.m),borderColor:'#718bff',backgroundColor:'#718bff12',fill:true,tension:.35,pointRadius:0,borderWidth:2,spanGaps:true},
      {label:'Disk',data:points.map(p=>p.d),borderColor:'#43d9a3',backgroundColor:'#43d9a30a',fill:false,tension:.25,pointRadius:0,borderWidth:2,spanGaps:true}
    ]},
    options:{responsive:true,maintainAspectRatio:false,interaction:{intersect:false,mode:'index'},
      plugins:{legend:{display:false},tooltip:{backgroundColor:'#101827',borderColor:'#2a3a50',borderWidth:1,displayColors:true}},
      scales:{x:{grid:{display:false},ticks:{color:'#8494aa',maxTicksLimit:8,maxRotation:0},border:{color:'#263348'}},
        y:{min:0,max:100,grid:{color:'#1d2a3c'},ticks:{color:'#8494aa',callback:v=>v+'%',maxTicksLimit:6},border:{display:false}}}}
  });
}

function renderServices(services, mode = 'sample') {
  const items = Array.isArray(services) ? services : [];
  const ok = items.filter(s => s.up).length;
  $('checks-ok').textContent = items.length ? `${ok}/${items.length}` : '—';
  $('checks-total').textContent = items.length ? (mode === 'live' ? 'services online' : 'sample states shown') : (mode === 'live' ? 'no service checks' : 'no sample data');
  $('service-list').replaceChildren();
  if (!items.length) {
    $('service-list').innerHTML = '<div class="empty">No availability data available.</div>';
    return;
  }
  for (const service of items) {
    const row = document.createElement('div');
    row.className = 'service-row';
    const left = document.createElement('div');
    left.className = 'service-left';
    const dot = document.createElement('span');
    dot.className = `status-dot${service.up ? '' : ' down'}`;
    const name = document.createElement('span');
    name.textContent = service.name;
    const state = document.createElement('span');
    state.className = `status-label${service.up ? '' : ' down'}`;
    state.textContent = mode === 'live'
      ? (service.up ? 'UP' : 'DOWN')
      : (Number.isFinite(service.passing) && Number.isFinite(service.total)
        ? `${service.passing}/${service.total} SAMPLE`
        : (service.up ? 'SAMPLE OK' : 'SAMPLE DOWN'));
    left.append(dot, name);
    row.append(left, state);
    $('service-list').append(row);
  }
}

async function load() {
  try {
    const response = await fetch(`data.json?v=${Date.now()}`, {cache:'no-store'});
    if (!response.ok) throw new Error('Snapshot not available');
    const data = await response.json();
    if (data.schema !== 1) throw new Error('Unsupported data schema');

    const mode = data.mode === 'live' ? 'live' : 'sample';
    const generatedAt = data.generated_at ? new Date(data.generated_at) : null;
    const generatedValid = generatedAt && Number.isFinite(generatedAt.getTime());
    const ageMs = generatedValid ? Math.max(0, Date.now() - generatedAt.getTime()) : null;
    const ageMinutes = ageMs === null ? null : Math.floor(ageMs / 60000);
    const ageLabel = ageMinutes === null ? 'Age unavailable'
      : ageMinutes < 60 ? `${ageMinutes}m old`
      : ageMinutes < 1440 ? `${Math.floor(ageMinutes / 60)}h ${ageMinutes % 60}m old`
      : `${Math.floor(ageMinutes / 1440)}d ${Math.floor(ageMinutes % 1440 / 60)}h old`;
    const generatedLabel = generatedValid
      ? generatedAt.toLocaleString([], {dateStyle:'medium', timeStyle:'short'})
      : 'Unknown snapshot date';
    const isLive = mode === 'live' && generatedValid;
    const isFresh = isLive && ageMinutes <= 20;
    const isStale = isLive && !isFresh;

    $('mode-pill').textContent = isFresh ? 'LIVE TELEMETRY' : isStale ? 'STALE TELEMETRY' : 'SYNTHETIC DEMO';
    $('dashboard-subtitle').textContent = isLive
      ? 'Host metrics and service availability published from Prometheus. This is a periodic snapshot, not a second-by-second stream.'
      : 'An illustrative dashboard preview. All displayed values and service states are synthetic; this page is not connected to live infrastructure.';
    $('dataset-label').textContent = isLive ? 'LAST METRICS UPDATE' : 'SAMPLE DATASET';
    $('dataset-note').textContent = isLive ? 'Prometheus snapshot · periodically refreshed' : 'Illustrative values · Not live telemetry';
    $('history-label').textContent = isLive ? 'LIVE HISTORY · 24H' : 'SAMPLE HISTORY · 24H';
    $('service-eyebrow').textContent = isLive ? 'AVAILABILITY' : 'EXAMPLE';
    $('service-title').textContent = isLive ? 'Service availability' : 'Sample service states';
    $('service-mode').textContent = isLive ? 'PROMETHEUS CHECKS' : 'SYNTHETIC';
    $('service-footnote').textContent = isLive
      ? 'Availability is based on the latest Prometheus Blackbox Exporter checks. Snapshot updates are periodic.'
      : 'These service states are sample values for demonstration only and are not real health checks.';
    $('notice-title').textContent = isLive ? (isStale ? 'Live snapshot is stale' : 'Live telemetry snapshot') : 'Synthetic demo only';
    $('notice-description').textContent = isLive
      ? 'Metrics are collected from the home server through Prometheus and published as a read-only snapshot. If this timestamp is older than 20 minutes, the telemetry pipeline may be offline. This public page does not expose the Prometheus API itself.'
      : 'All metrics, timestamps, charts, and service states on this page are illustrative sample data. This public page does not query the home server or prove current service availability.';
    $('mode-notice').style.borderColor = isFresh ? '#245344' : isStale ? '#653342' : '#25394b';

    setMetric('cpu','cpu-bar',data.current.cpu,'cpu-note','%',isLive ? 'Latest telemetry' : 'Latest sample');
    setMetric('memory','memory-bar',data.current.memory,'memory-note','%',isLive ? 'Latest telemetry' : 'Latest sample');
    setMetric('disk','disk-bar',data.current.disk,'disk-note','%',isLive ? 'Latest telemetry' : 'Latest sample');
    $('disk-detail').textContent = Number.isFinite(data.current.disk) ? `${data.current.disk.toFixed(1)}%` : '—';
    $('disk-bar-2').style.width = `${Math.max(0,Math.min(100,data.current.disk || 0))}%`;

    $('load-average').textContent = Number.isFinite(data.current.load) ? data.current.load.toFixed(2) : '—';
    $('memory-available').textContent = Number.isFinite(data.current.memory_available_gb) ? `${data.current.memory_available_gb.toFixed(2)} GB` : '—';
    $('memory-capacity').textContent = Number.isFinite(data.current.memory_total_gb) ? `of ${data.current.memory_total_gb.toFixed(2)} GB total` : 'Available system memory';
    $('disk-available').textContent = Number.isFinite(data.current.disk_available_gb) ? `${data.current.disk_available_gb.toFixed(1)} GB` : '—';
    $('disk-capacity').textContent = Number.isFinite(data.current.disk_total_gb) ? `of ${data.current.disk_total_gb.toFixed(1)} GB total` : 'Available system storage';
    $('network-rx').textContent = Number.isFinite(data.current.network_rx_mbps) ? data.current.network_rx_mbps.toFixed(3) : '—';
    $('network-tx').textContent = Number.isFinite(data.current.network_tx_mbps) ? data.current.network_tx_mbps.toFixed(3) : '—';

    $('uptime').textContent = duration(data.current.uptime);
    $('uptime-detail').textContent = duration(data.current.uptime);
    $('uptime-bar').style.width = `${Math.min(100,((data.current.uptime || 0)%604800)/604800*100)}%`;
    renderChart(data.history);
    renderServices(data.services, mode);

    $('updated').textContent = generatedLabel;
    $('updated-top').textContent = isFresh
      ? `LIVE · ${ageLabel.toUpperCase()}`
      : isStale
        ? `STALE · ${ageLabel.toUpperCase()}`
        : `SAMPLE · ${ageLabel.toUpperCase()}`;
    $('footer-time').textContent = `${isLive ? 'Snapshot' : 'Sample generated'} ${generatedLabel} · ${ageLabel}`;
    $('snapshot-age').textContent = ageLabel;

    $('overall-status').textContent = isFresh ? 'LIVE TELEMETRY' : isStale ? 'STALE TELEMETRY' : 'DEMO MODE';
    const dot = document.querySelector('.live-dot');
    dot.style.background = isFresh ? 'var(--green)' : isStale ? 'var(--red)' : '#718bff';
    dot.title = isFresh ? 'Live Prometheus snapshot updated within 20 minutes' : isStale ? 'Live telemetry snapshot is older than 20 minutes' : 'Synthetic sample data; no live monitoring connection';
  } catch (error) {
    $('overall-status').textContent = 'SNAPSHOT UNAVAILABLE';
    $('updated-top').textContent = 'LOAD FAILED';
    $('snapshot-age').textContent = 'Unavailable';
    document.querySelector('.live-dot').style.background = 'var(--red)';
    document.querySelector('.live-dot').title = 'Unable to load the published dashboard snapshot';
    console.error('Synthetic demo data could not be loaded:', error);
  }
}
load();
setInterval(load, 60000);
