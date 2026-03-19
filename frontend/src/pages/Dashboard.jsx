import React, { useEffect, useState } from 'react';
import useAuthStore from '../store/authStore';

export default function Dashboard() {
  const user = useAuthStore((s) => s.user);
  const [stats, setStats] = useState({ orders: 0, products: 0, notifications: 0 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      fetch('/api/orders').then((r) => r.json()),
      fetch('/api/products').then((r) => r.json()),
      fetch('/api/notifications').then((r) => r.json()),
    ]).then(([orders, products, notifications]) => {
      setStats({
        orders: Array.isArray(orders) ? orders.length : 0,
        products: Array.isArray(products) ? products.length : 0,
        notifications: Array.isArray(notifications) ? notifications.length : 0,
      });
    }).catch(console.error).finally(() => setLoading(false));
  }, []);

  return (
    <div className="dashboard">
      <h1>Welcome back, {user?.name || 'User'}</h1>
      {loading ? <p>Loading stats...</p> : (
        <div className="stats-grid">
          <div className="stat-card"><h3>{stats.orders}</h3><p>Total Orders</p></div>
          <div className="stat-card"><h3>{stats.products}</h3><p>Products</p></div>
          <div className="stat-card"><h3>{stats.notifications}</h3><p>Notifications</p></div>
        </div>
      )}
    </div>
  );
}
