import React, { useEffect, useState } from 'react';

export default function AdminLogs() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('');

  useEffect(() => {
    fetch('/api/admin/logs').then((r) => r.json()).then(setLogs).finally(() => setLoading(false));
  }, []);

  const filtered = logs.filter((l) =>
    (l.action || '').toLowerCase().includes(filter.toLowerCase()) ||
    (l.resource || '').toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <div className="page">
      <div className="page-header">
        <h1>Audit Logs</h1>
        <input placeholder="Filter logs..." value={filter} onChange={(e) => setFilter(e.target.value)} />
      </div>
      {loading ? <p>Loading logs...</p> : (
        <table className="admin-table">
          <thead>
            <tr><th>ID</th><th>Action</th><th>User</th><th>Resource</th><th>Timestamp</th></tr>
          </thead>
          <tbody>
            {filtered.map((l) => (
              <tr key={l.id}>
                <td>{l.id}</td>
                <td><span className="log-action">{l.action}</span></td>
                <td>{l.userId}</td>
                <td>{l.resource}</td>
                <td>{new Date(l.timestamp).toLocaleString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
