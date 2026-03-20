import { create } from 'zustand';

const useOrderStore = create((set) => ({
  orders: [],
  loading: false,
  error: null,

  fetchOrders: async () => {
    set({ loading: true, error: null });
    try {
      const res = await fetch('/api/orders');
      const data = await res.json();
      set({ orders: Array.isArray(data) ? data : [], loading: false });
    } catch (err) {
      set({ error: err.message, loading: false });
    }
  },

  createOrder: async (payload) => {
    const res = await fetch('/api/orders', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    if (!res.ok) throw new Error('Failed to create order');
    const order = await res.json();
    set((state) => ({ orders: [order, ...state.orders] }));
    return order;
  },
}));

export default useOrderStore;
