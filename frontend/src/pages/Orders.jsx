import React, { useEffect, useState } from 'react';

const STATUS_COLORS = {
  PENDING: '#f59e0b',
  PROCESSING: '#3b82f6',
  SHIPPED: '#8b5cf6',
  DELIVERED: '#10b981',
  CANCELLED: '#ef4444'
};

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/orders')
      .then((r) => r.json())
      .then(setOrders)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <p>Loading orders...</p>;

  return (
    <div className="page">
      <h1>My Orders</h1>
      {orders.length === 0 ? (
        <p className="empty">No orders found.</p>
      ) : (
        <div className="orders-list">
          {orders.map((o) => (
            <div key={o.id} className="order-card">
              <div className="order-header">
                <span className="order-id">Order #{o.id}</span>
                <span className="status-badge" style={{ background: STATUS_COLORS[o.status] || '#6b7280' }}>
                  {o.status}
                </span>
              </div>
              <p>User ID: {o.userId}</p>
              <p>Total: USD {parseFloat(o.total || 0).toFixed(2)}</p>
              <p className="order-date">{new Date(o.createdAt).toLocaleDateString()}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
