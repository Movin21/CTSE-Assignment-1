const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(helmet());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'api-gateway', timestamp: new Date().toISOString() });
});

app.use('/api/identity', createProxyMiddleware({
  target: process.env.IDENTITY_SERVICE_URL || 'http://localhost:8081',
  changeOrigin: true,
  pathRewrite: { '^/api/identity': '' },
}));

app.use('/api/orders', createProxyMiddleware({
  target: process.env.ORDER_SERVICE_URL || 'http://localhost:3001',
  changeOrigin: true,
  pathRewrite: { '^/api/orders': '' },
}));

app.use('/api/products', createProxyMiddleware({
  target: process.env.PRODUCT_SERVICE_URL || 'http://localhost:8082',
  changeOrigin: true,
  pathRewrite: { '^/api/products': '' },
}));

app.use('/api/notifications', createProxyMiddleware({
  target: process.env.NOTIFICATION_SERVICE_URL || 'http://localhost:3002',
  changeOrigin: true,
  pathRewrite: { '^/api/notifications': '' },
}));

app.listen(PORT, () => {
  console.log('API Gateway running on port ' + PORT);
});
