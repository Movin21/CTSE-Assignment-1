import React, { useEffect, useState } from 'react';

export default function Products() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ name: '', price: '', stock: '', description: '', category: '' });

  useEffect(() => {
    fetch('/api/products')
      .then((r) => r.json())
      .then(setProducts)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const handleCreate = async (e) => {
    e.preventDefault();
    const res = await fetch('/api/products', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...form, price: parseFloat(form.price), stock: parseInt(form.stock) }),
    });
    if (res.ok) {
      const p = await res.json();
      setProducts([...products, p]);
      setShowForm(false);
      setForm({ name: '', price: '', stock: '', description: '', category: '' });
    }
  };

  if (loading) return <p>Loading products...</p>;

  return (
    <div className="page">
      <div className="page-header">
        <h1>Product Catalog</h1>
        <button onClick={() => setShowForm(!showForm)}>+ Add Product</button>
      </div>
      {showForm && (
        <form onSubmit={handleCreate} className="inline-form">
          <input placeholder="Name" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
          <input placeholder="Price" type="number" step="0.01" value={form.price} onChange={(e) => setForm({ ...form, price: e.target.value })} required />
          <input placeholder="Stock" type="number" value={form.stock} onChange={(e) => setForm({ ...form, stock: e.target.value })} required />
          <input placeholder="Category" value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })} />
          <button type="submit">Save</button>
        </form>
      )}
      <div className="card-grid">
        {products.map((p) => (
          <div key={p.id} className="product-card">
            <h3>{p.name}</h3>
            <p className="price">USD {parseFloat(p.price).toFixed(2)}</p>
            <p>Stock: {p.stock}</p>
            {p.category && <span className="badge">{p.category}</span>}
          </div>
        ))}
      </div>
    </div>
  );
}
