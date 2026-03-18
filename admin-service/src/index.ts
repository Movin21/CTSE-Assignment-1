import express from 'express';
import cors from 'cors';
import helmet from 'helmet';

const app = express();
const PORT = process.env.PORT || 3003;

app.use(cors());
app.use(helmet());
app.use(express.json());

interface AuditLog {
  id: number;
  action: string;
  userId: number;
  resource: string;
  timestamp: string;
}

const logs: AuditLog[] = [];
let logId = 1;

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'admin-service' });
});

app.get('/logs', (_req, res) => res.json(logs));

app.post('/logs', (req, res) => {
  const { action, userId, resource } = req.body;
  const log: AuditLog = { id: logId++, action, userId, resource, timestamp: new Date().toISOString() };
  logs.push(log);
  res.status(201).json(log);
});

app.listen(PORT, () => console.log('Admin service running on port ' + PORT));
