const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors({ origin: process.env.ALLOWED_ORIGIN || '*' }));
app.use(helmet());
app.use(morgan('combined'));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'api-gateway',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

const services = {
  '/api/identity':      process.env.IDENTITY_SERVICE_URL      || 'http://identity-service:8081',
  '/api/orders':        process.env.ORDER_SERVICE_URL          || 'http://order-service:3001',
  '/api/products':      process.env.PRODUCT_SERVICE_URL        || 'http://product-service:8082',
  '/api/notifications': process.env.NOTIFICATION_SERVICE_URL  || 'http://notification-service:3002',
  '/api/admin':         process.env.ADMIN_SERVICE_URL          || 'http://admin-service:3003',
};

Object.entries(services).forEach(([path, target]) => {
  app.use(path, createProxyMiddleware({
    target,
    changeOrigin: true,
    pathRewrite: { ['^' + path]: '' },
    on: {
      error: (err, req, res) => {
        console.error('Proxy error for ' + path + ':', err.message);
        res.status(502).json({ error: 'Service temporarily unavailable' });
      },
    },
  }));
});

app.listen(PORT, () => {
  console.log('API Gateway running on port ' + PORT);
  console.log('Registered routes:', Object.keys(services));
});
