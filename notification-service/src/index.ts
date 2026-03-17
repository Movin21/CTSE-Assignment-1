import express from 'express';
import cors from 'cors';
import { connectRabbitMQ } from './rabbitmq';

const app = express();
const PORT = process.env.PORT || 3002;

app.use(cors());
app.use(express.json());

const notifications: object[] = [];

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'notification-service' });
});

app.get('/notifications', (_req, res) => {
  res.json(notifications);
});

async function start() {
  await connectRabbitMQ(notifications);
  app.listen(PORT, () => console.log('Notification service running on port ' + PORT));
}

start().catch(console.error);
