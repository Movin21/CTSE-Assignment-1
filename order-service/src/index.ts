import express from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'order-service' });
});

app.get('/orders', async (_req, res) => {
  try {
    const orders = await prisma.order.findMany({ include: { items: true } });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

app.post('/orders', async (req, res) => {
  try {
    const { userId, items } = req.body;
    const total = items.reduce((sum: number, i: any) => sum + i.price * i.quantity, 0);
    const order = await prisma.order.create({
      data: {
        userId,
        total,
        status: 'PENDING',
        items: { create: items },
      },
      include: { items: true },
    });
    res.status(201).json(order);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create order' });
  }
});

app.listen(PORT, () => console.log('Order service running on port ' + PORT));
