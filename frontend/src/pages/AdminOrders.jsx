import React, { useEffect, useState } from 'react';

const STATUSES = ['PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

export default function AdminOrders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/orders').then((r) => r.json()).then(setOrders).finally(() => setLoading(false));
  }, []);

  const updateStatus = async (id, status) => {
    await fetch('/api/orders/' + id + '/status', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status }),
    });
    setOrders(orders.map((o) => (o.id === id ? { ...o, status } : o)));
  };

  if (loading) return <p>Loading...</p>;

  return (
    <div className="page">
      <h1>Manage Orders</h1>
      <table className="admin-table">
        <thead>
          <tr><th>ID</th><th>User</th><th>Total</th><th>Status</th><th>Update</th></tr>
        </thead>
        <tbody>
          {orders.map((o) => (
            <tr key={o.id}>
              <td>#{o.id}</td>
              <td>{o.userId}</td>
              <td>USD {parseFloat(o.total || 0).toFixed(2)}</td>
              <td><span className={'status ' + (o.status || '').toLowerCase()}>{o.status}</span></td>
              <td>
                <select value={o.status} onChange={(e) => updateStatus(o.id, e.target.value)}>
                  {STATUSES.map((s) => <option key={s} value={s}>{s}</option>)}
                </select>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
