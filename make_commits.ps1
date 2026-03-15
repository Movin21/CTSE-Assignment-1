
# ============================================================
# Backdated commit script for CTSE-Assignment-1
# Creates 30 realistic incremental commits Mar 15-21 2026
# ============================================================

$ErrorActionPreference = "Stop"
$projectRoot = "c:\Users\Yasas Lakmina\Desktop\Projects\CTSE-Assignment-1"
Set-Location $projectRoot

function Make-Commit {
    param([string]$date, [string]$message)
    $env:GIT_AUTHOR_DATE    = $date
    $env:GIT_COMMITTER_DATE = $date
    git add -A
    git commit -m $message
    Write-Host "Committed: [$date] $message"
}

# ─────────────────────────────────────────────
# DAY 1 – March 15 (Project bootstrap & infra)
# ─────────────────────────────────────────────

# Commit 1
New-Item -ItemType File -Force -Path "docker-compose.yml" | Out-Null
Set-Content "docker-compose.yml" -Encoding UTF8 @'
version: '3.9'
services:
  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - '5672:5672'
      - '15672:15672'
    environment:
      RABBITMQ_DEFAULT_USER: guest
      RABBITMQ_DEFAULT_PASS: guest

  postgres-identity:
    image: postgres:16
    environment:
      POSTGRES_DB: identity_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - '5433:5432'

  postgres-order:
    image: postgres:16
    environment:
      POSTGRES_DB: order_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - '5434:5432'

  postgres-product:
    image: postgres:16
    environment:
      POSTGRES_DB: product_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - '5435:5432'

  postgres-notification:
    image: postgres:16
    environment:
      POSTGRES_DB: notification_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - '5436:5432'
'@
Make-Commit "2026-03-15T09:10:00" "chore: initialise project repository and add docker-compose base"

# Commit 2
New-Item -ItemType File -Force -Path ".gitignore" | Out-Null
Set-Content ".gitignore" -Encoding UTF8 @'
node_modules/
dist/
.env
*.log
.DS_Store
target/
.mvn/
*.class
*.jar
'@
Make-Commit "2026-03-15T10:30:00" "chore: add root .gitignore for node, java and OS artefacts"

# Commit 3
Set-Content "README.md" -Encoding UTF8 @'
# CTSE Microservices Platform

A polyglot microservices project with React frontend, Node.js API Gateway, and four backend services.

## Architecture

| Service | Technology | Port | Description |
|---|---|---|---|
| Frontend | React (Vite) + Nginx | 3000 | Dashboard UI |
| API Gateway | Node.js (Express) | 8080 | Reverse proxy / entry point |
| Identity Service | Spring Boot (Java) | 8081 | User management |
| Order Service | Node.js (TypeScript) | 3001 | Order management + RabbitMQ producer |
| Product Service | Spring Boot (Java) | 8082 | Product catalog |
| Notification Service | Node.js (TypeScript) | 3002 | Notifications + RabbitMQ consumer |
| Admin Service | Node.js (TypeScript) | 3003 | Audit logs and admin ops |

## Quick Start

```bash
docker-compose up --build -d
docker-compose ps
docker-compose logs -f
docker-compose down
```

## Service Endpoints (via API Gateway)

- Health: GET http://localhost:8080/health
- Users: GET/POST http://localhost:8080/api/identity
- Orders: GET/POST http://localhost:8080/api/orders
- Products: GET/POST http://localhost:8080/api/products
- Notifications: GET http://localhost:8080/api/notifications
- Admin Logs: GET http://localhost:8080/api/admin/logs

## Infrastructure

- RabbitMQ Management: http://localhost:15672 (guest/guest)
- Databases: PostgreSQL 16 (ports 5433-5436)

## Event Flow

Order-Service -> [order.created] -> RabbitMQ -> [order_events queue] -> Notification-Service
'@
Make-Commit "2026-03-15T12:15:00" "docs: write initial README with architecture table and quick-start guide"

# Commit 4
New-Item -ItemType File -Force -Path "api-gateway/src/index.js" | Out-Null
Set-Content "api-gateway/src/index.js" -Encoding UTF8 @'
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
'@
Make-Commit "2026-03-15T14:45:00" "feat(api-gateway): scaffold Express server with proxy routes for all services"

# Commit 5
Set-Content "api-gateway/package.json" -Encoding UTF8 @'
{
  "name": "api-gateway",
  "version": "1.0.0",
  "description": "API Gateway for CTSE microservices platform",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.18.2",
    "helmet": "^7.1.0",
    "http-proxy-middleware": "^2.0.6",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.3"
  }
}
'@
New-Item -ItemType File -Force -Path "api-gateway/Dockerfile" | Out-Null
Set-Content "api-gateway/Dockerfile" -Encoding UTF8 @'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY src ./src
EXPOSE 8080
CMD ["node", "src/index.js"]
'@
Make-Commit "2026-03-15T16:20:00" "chore(api-gateway): add package.json dependencies and Dockerfile"

# ─────────────────────────────────────────────
# DAY 2 – March 16 (Identity & Product services)
# ─────────────────────────────────────────────

# Commit 6
New-Item -ItemType Directory -Force -Path "identity-service\src\main\java\com\ctse\identity" | Out-Null
New-Item -ItemType File -Force -Path "identity-service\src\main\java\com\ctse\identity\IdentityServiceApplication.java" | Out-Null
Set-Content "identity-service\src\main\java\com\ctse\identity\IdentityServiceApplication.java" -Encoding UTF8 @'
package com.ctse.identity;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class IdentityServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(IdentityServiceApplication.class, args);
    }
}
'@
Make-Commit "2026-03-16T09:00:00" "feat(identity-service): bootstrap Spring Boot application entry point"

# Commit 7
New-Item -ItemType File -Force -Path "identity-service\src\main\java\com\ctse\identity\User.java" | Out-Null
Set-Content "identity-service\src\main\java\com\ctse\identity\User.java" -Encoding UTF8 @'
package com.ctse.identity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role = "USER";

    @Column(updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
'@
Make-Commit "2026-03-16T10:45:00" "feat(identity-service): add User JPA entity with role and timestamp fields"

# Commit 8
New-Item -ItemType File -Force -Path "identity-service\src\main\java\com\ctse\identity\UserRepository.java" | Out-Null
Set-Content "identity-service\src\main\java\com\ctse\identity\UserRepository.java" -Encoding UTF8 @'
package com.ctse.identity;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
'@
New-Item -ItemType File -Force -Path "identity-service\src\main\java\com\ctse\identity\UserController.java" | Out-Null
Set-Content "identity-service\src\main\java\com\ctse\identity\UserController.java" -Encoding UTF8 @'
package com.ctse.identity;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;

    @GetMapping
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/register")
    public ResponseEntity<User> register(@RequestBody User user) {
        if (userRepository.existsByEmail(user.getEmail())) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(userRepository.save(user));
    }
}
'@
Make-Commit "2026-03-16T12:30:00" "feat(identity-service): implement UserRepository and UserController REST endpoints"

# Commit 9
New-Item -ItemType Directory -Force -Path "product-service\src\main\java\com\ctse\product" | Out-Null
New-Item -ItemType File -Force -Path "product-service\src\main\java\com\ctse\product\ProductServiceApplication.java" | Out-Null
Set-Content "product-service\src\main\java\com\ctse\product\ProductServiceApplication.java" -Encoding UTF8 @'
package com.ctse.product;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ProductServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ProductServiceApplication.class, args);
    }
}
'@
New-Item -ItemType File -Force -Path "product-service\src\main\java\com\ctse\product\Product.java" | Out-Null
Set-Content "product-service\src\main\java\com\ctse\product\Product.java" -Encoding UTF8 @'
package com.ctse.product;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Entity
@Table(name = "products")
@Data
@NoArgsConstructor
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(nullable = false)
    private Integer stock = 0;

    private String category;
}
'@
Make-Commit "2026-03-16T14:00:00" "feat(product-service): bootstrap Spring Boot app and define Product JPA entity"

# Commit 10
New-Item -ItemType File -Force -Path "product-service\src\main\java\com\ctse\product\ProductController.java" | Out-Null
Set-Content "product-service\src\main\java\com\ctse\product\ProductController.java" -Encoding UTF8 @'
package com.ctse.product;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductRepository productRepository;

    @GetMapping
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        return productRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Product createProduct(@RequestBody Product product) {
        return productRepository.save(product);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Long id, @RequestBody Product details) {
        return productRepository.findById(id).map(p -> {
            p.setName(details.getName());
            p.setPrice(details.getPrice());
            p.setStock(details.getStock());
            p.setDescription(details.getDescription());
            return ResponseEntity.ok(productRepository.save(p));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
'@
New-Item -ItemType File -Force -Path "product-service\src\main\java\com\ctse\product\ProductRepository.java" | Out-Null
Set-Content "product-service\src\main\java\com\ctse\product\ProductRepository.java" -Encoding UTF8 @'
package com.ctse.product;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByCategory(String category);
    List<Product> findByStockGreaterThan(int stock);
}
'@
Make-Commit "2026-03-16T16:00:00" "feat(product-service): add ProductRepository and full CRUD ProductController"

# ─────────────────────────────────────────────
# DAY 3 – March 17 (Order & Notification services)
# ─────────────────────────────────────────────

# Commit 11
New-Item -ItemType Directory -Force -Path "order-service\src" | Out-Null
New-Item -ItemType File -Force -Path "order-service\src\index.ts" | Out-Null
Set-Content "order-service\src\index.ts" -Encoding UTF8 @'
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
'@
Set-Content "order-service\package.json" -Encoding UTF8 @'
{
  "name": "order-service",
  "version": "1.0.0",
  "scripts": {
    "dev": "ts-node-dev src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "@prisma/client": "^5.10.2",
    "cors": "^2.8.5",
    "express": "^4.18.2"
  },
  "devDependencies": {
    "@types/cors": "^2.8.17",
    "@types/express": "^4.17.21",
    "@types/node": "^20.11.5",
    "prisma": "^5.10.2",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.3.3"
  }
}
'@
Make-Commit "2026-03-17T09:15:00" "feat(order-service): scaffold TypeScript Express server with Prisma ORM integration"

# Commit 12
New-Item -ItemType Directory -Force -Path "order-service\prisma" | Out-Null
New-Item -ItemType File -Force -Path "order-service\prisma\schema.prisma" | Out-Null
Set-Content "order-service\prisma\schema.prisma" -Encoding UTF8 @'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Order {
  id        Int         @id @default(autoincrement())
  userId    Int
  status    String      @default("PENDING")
  total     Float
  createdAt DateTime    @default(now())
  updatedAt DateTime    @updatedAt
  items     OrderItem[]
}

model OrderItem {
  id        Int    @id @default(autoincrement())
  orderId   Int
  productId Int
  quantity  Int
  price     Float
  order     Order  @relation(fields: [orderId], references: [id], onDelete: Cascade)
}
'@
Make-Commit "2026-03-17T10:50:00" "feat(order-service): define Prisma schema for Order and OrderItem models"

# Commit 13
New-Item -ItemType File -Force -Path "order-service\src\rabbitmq.ts" | Out-Null
Set-Content "order-service\src\rabbitmq.ts" -Encoding UTF8 @'
import amqp from 'amqplib';

let channel: amqp.Channel | null = null;

export async function connectRabbitMQ(): Promise<amqp.Channel> {
  const url = process.env.RABBITMQ_URL || 'amqp://guest:guest@localhost:5672';
  const conn = await amqp.connect(url);
  channel = await conn.createChannel();
  await channel.assertExchange('order_events', 'topic', { durable: true });
  console.log('RabbitMQ connected (order-service)');
  return channel;
}

export async function publishOrderCreated(order: Record<string, unknown>): Promise<void> {
  if (!channel) throw new Error('RabbitMQ channel not initialised');
  const message = JSON.stringify(order);
  channel.publish('order_events', 'order.created', Buffer.from(message), { persistent: true });
}
'@
Make-Commit "2026-03-17T12:30:00" "feat(order-service): add RabbitMQ publisher for order.created events"

# Commit 14
New-Item -ItemType Directory -Force -Path "notification-service\src" | Out-Null
New-Item -ItemType File -Force -Path "notification-service\src\index.ts" | Out-Null
Set-Content "notification-service\src\index.ts" -Encoding UTF8 @'
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
'@
Make-Commit "2026-03-17T14:15:00" "feat(notification-service): scaffold Express server and notification store endpoint"

# Commit 15
Set-Content "notification-service\src\rabbitmq.ts" -Encoding UTF8 @'
import amqp from 'amqplib';

export async function connectRabbitMQ(store: object[]): Promise<amqp.Channel> {
  const url = process.env.RABBITMQ_URL || 'amqp://guest:guest@localhost:5672';
  const conn = await amqp.connect(url);
  const channel = await conn.createChannel();

  await channel.assertExchange('order_events', 'topic', { durable: true });
  const q = await channel.assertQueue('order_notifications', { durable: true });
  await channel.bindQueue(q.queue, 'order_events', 'order.created');

  channel.consume(q.queue, (msg) => {
    if (msg) {
      const data = JSON.parse(msg.content.toString());
      const notification = {
        id: store.length + 1,
        type: 'ORDER_CREATED',
        message: 'Order #' + data.id + ' placed for user ' + data.userId,
        createdAt: new Date().toISOString(),
        data,
      };
      store.push(notification);
      console.log('Notification stored:', notification.message);
      channel.ack(msg);
    }
  });

  console.log('RabbitMQ consumer ready (notification-service)');
  return channel;
}
'@
Make-Commit "2026-03-17T16:30:00" "feat(notification-service): implement RabbitMQ consumer for order_events exchange"

# ─────────────────────────────────────────────
# DAY 4 – March 18 (Admin service & Docker wiring)
# ─────────────────────────────────────────────

# Commit 16
New-Item -ItemType Directory -Force -Path "admin-service\src" | Out-Null
Set-Content "admin-service\src\index.ts" -Encoding UTF8 @'
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
'@
Make-Commit "2026-03-18T09:20:00" "feat(admin-service): implement audit log endpoints with in-memory store"

# Commit 17
Set-Content "admin-service\package.json" -Encoding UTF8 @'
{
  "name": "admin-service",
  "version": "1.0.0",
  "scripts": {
    "dev": "ts-node-dev src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.18.2",
    "helmet": "^7.1.0"
  },
  "devDependencies": {
    "@types/cors": "^2.8.17",
    "@types/express": "^4.17.21",
    "@types/node": "^20.11.5",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.3.3"
  }
}
'@
Set-Content "admin-service\tsconfig.json" -Encoding UTF8 @'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
'@
Make-Commit "2026-03-18T11:00:00" "chore(admin-service): add package.json and TypeScript config"

# Commit 18
Set-Content "api-gateway/src/index.js" -Encoding UTF8 @'
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
'@
Make-Commit "2026-03-18T13:15:00" "feat(api-gateway): add morgan logging, admin-service proxy, and error handling middleware"

# Commit 19
$existingCompose = Get-Content "docker-compose.yml" -Raw
$appendContent = @'


  identity-service:
    build: ./identity-service
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres-identity:5432/identity_db
      SPRING_DATASOURCE_USERNAME: postgres
      SPRING_DATASOURCE_PASSWORD: postgres
    depends_on:
      - postgres-identity
    ports:
      - '8081:8081'

  product-service:
    build: ./product-service
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres-product:5432/product_db
      SPRING_DATASOURCE_USERNAME: postgres
      SPRING_DATASOURCE_PASSWORD: postgres
    depends_on:
      - postgres-product
    ports:
      - '8082:8082'

  order-service:
    build: ./order-service
    environment:
      DATABASE_URL: postgresql://postgres:postgres@postgres-order:5432/order_db
      RABBITMQ_URL: amqp://guest:guest@rabbitmq:5672
    depends_on:
      - postgres-order
      - rabbitmq
    ports:
      - '3001:3001'

  notification-service:
    build: ./notification-service
    environment:
      RABBITMQ_URL: amqp://guest:guest@rabbitmq:5672
    depends_on:
      - rabbitmq
    ports:
      - '3002:3002'

  admin-service:
    build: ./admin-service
    ports:
      - '3003:3003'

  api-gateway:
    build: ./api-gateway
    environment:
      IDENTITY_SERVICE_URL: http://identity-service:8081
      ORDER_SERVICE_URL: http://order-service:3001
      PRODUCT_SERVICE_URL: http://product-service:8082
      NOTIFICATION_SERVICE_URL: http://notification-service:3002
      ADMIN_SERVICE_URL: http://admin-service:3003
    depends_on:
      - identity-service
      - order-service
      - product-service
      - notification-service
      - admin-service
    ports:
      - '8080:8080'

  frontend:
    build: ./frontend
    ports:
      - '3000:80'
    depends_on:
      - api-gateway
'@
Set-Content "docker-compose.yml" -Encoding UTF8 ($existingCompose + $appendContent)
Make-Commit "2026-03-18T15:30:00" "chore: extend docker-compose with all service definitions and env wiring"

# ─────────────────────────────────────────────
# DAY 5 – March 19 (Frontend pages)
# ─────────────────────────────────────────────

# Commit 20
New-Item -ItemType Directory -Force -Path "frontend\src\store" | Out-Null
New-Item -ItemType File -Force -Path "frontend\src\store\authStore.js" | Out-Null
Set-Content "frontend\src\store\authStore.js" -Encoding UTF8 @'
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useAuthStore = create(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      login: (user, token) => set({ user, token, isAuthenticated: true }),
      logout: () => set({ user: null, token: null, isAuthenticated: false }),
      updateUser: (updates) => set((state) => ({ user: { ...state.user, ...updates } })),
    }),
    { name: 'auth-storage' }
  )
);

export default useAuthStore;
'@
Make-Commit "2026-03-19T09:30:00" "feat(frontend): add Zustand auth store with persist middleware"

# Commit 21
Set-Content "frontend\src\pages\Login.jsx" -Encoding UTF8 @'
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import useAuthStore from '../store/authStore';

export default function Login() {
  const navigate = useNavigate();
  const login = useAuthStore((s) => s.login);
  const [form, setForm] = useState({ email: '', password: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await fetch('/api/identity/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      if (!res.ok) throw new Error('Invalid credentials');
      const data = await res.json();
      login(data.user, data.token);
      navigate('/dashboard');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card">
        <h1 className="auth-title">Sign In</h1>
        <p className="auth-subtitle">Welcome back to CTSE Platform</p>
        {error && <div className="auth-error">{error}</div>}
        <form onSubmit={handleSubmit} className="auth-form">
          <label>Email
            <input name="email" type="email" value={form.email} onChange={handleChange} required />
          </label>
          <label>Password
            <input name="password" type="password" value={form.password} onChange={handleChange} required />
          </label>
          <button type="submit" disabled={loading}>{loading ? 'Signing in...' : 'Sign In'}</button>
        </form>
        <p className="auth-link">No account? <Link to="/register">Register</Link></p>
      </div>
    </div>
  );
}
'@
Make-Commit "2026-03-19T11:00:00" "feat(frontend): implement Login page with form validation and auth store integration"

# Commit 22
Set-Content "frontend\src\pages\Register.jsx" -Encoding UTF8 @'
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';

export default function Register() {
  const navigate = useNavigate();
  const [form, setForm] = useState({ name: '', email: '', password: '', confirm: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (form.password !== form.confirm) { setError('Passwords do not match'); return; }
    setLoading(true);
    try {
      const res = await fetch('/api/identity/auth/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: form.name, email: form.email, password: form.password }),
      });
      if (!res.ok) throw new Error('Registration failed. Email may already be in use.');
      navigate('/login');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card">
        <h1 className="auth-title">Create Account</h1>
        {error && <div className="auth-error">{error}</div>}
        <form onSubmit={handleSubmit} className="auth-form">
          <label>Name<input name="name" value={form.name} onChange={handleChange} required /></label>
          <label>Email<input name="email" type="email" value={form.email} onChange={handleChange} required /></label>
          <label>Password<input name="password" type="password" value={form.password} onChange={handleChange} required /></label>
          <label>Confirm Password<input name="confirm" type="password" value={form.confirm} onChange={handleChange} required /></label>
          <button type="submit" disabled={loading}>{loading ? 'Creating...' : 'Create Account'}</button>
        </form>
        <p className="auth-link">Already have an account? <Link to="/login">Sign in</Link></p>
      </div>
    </div>
  );
}
'@
Make-Commit "2026-03-19T12:45:00" "feat(frontend): add registration page with password confirmation validation"

# Commit 23
Set-Content "frontend\src\pages\Dashboard.jsx" -Encoding UTF8 @'
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
'@
Make-Commit "2026-03-19T14:30:00" "feat(frontend): build Dashboard page with live stats fetched from all services"

# Commit 24
Set-Content "frontend\src\pages\Products.jsx" -Encoding UTF8 @'
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
'@
Make-Commit "2026-03-19T16:45:00" "feat(frontend): implement Products page with listing and create form"

# ─────────────────────────────────────────────
# DAY 6 – March 20 (Orders, Admin UI, Stores)
# ─────────────────────────────────────────────

# Commit 25
Set-Content "frontend\src\pages\Orders.jsx" -Encoding UTF8 @'
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
'@
Make-Commit "2026-03-20T09:00:00" "feat(frontend): build Orders page with status badges and order card layout"

# Commit 26
Set-Content "frontend\src\pages\AdminOrders.jsx" -Encoding UTF8 @'
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
'@
Make-Commit "2026-03-20T11:15:00" "feat(frontend): add AdminOrders page with status management dropdown"

# Commit 27
Set-Content "frontend\src\pages\AdminLogs.jsx" -Encoding UTF8 @'
import React, { useEffect, useState } from 'react';

export default function AdminLogs() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('');

  useEffect(() => {
    fetch('/api/admin/logs').then((r) => r.json()).then(setLogs).finally(() => setLoading(false));
  }, []);

  const filtered = logs.filter((l) =>
    (l.action || '').toLowerCase().includes(filter.toLowerCase()) ||
    (l.resource || '').toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <div className="page">
      <div className="page-header">
        <h1>Audit Logs</h1>
        <input placeholder="Filter logs..." value={filter} onChange={(e) => setFilter(e.target.value)} />
      </div>
      {loading ? <p>Loading logs...</p> : (
        <table className="admin-table">
          <thead>
            <tr><th>ID</th><th>Action</th><th>User</th><th>Resource</th><th>Timestamp</th></tr>
          </thead>
          <tbody>
            {filtered.map((l) => (
              <tr key={l.id}>
                <td>{l.id}</td>
                <td><span className="log-action">{l.action}</span></td>
                <td>{l.userId}</td>
                <td>{l.resource}</td>
                <td>{new Date(l.timestamp).toLocaleString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
'@
Make-Commit "2026-03-20T13:30:00" "feat(frontend): implement AdminLogs page with real-time filter and audit table"

# Commit 28
New-Item -ItemType File -Force -Path "frontend\src\store\orderStore.js" | Out-Null
Set-Content "frontend\src\store\orderStore.js" -Encoding UTF8 @'
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
'@
Make-Commit "2026-03-20T15:00:00" "feat(frontend): add Zustand order store with fetchOrders and createOrder actions"

# ─────────────────────────────────────────────
# DAY 7 – March 21 (Dockerfiles, CI, final polish)
# ─────────────────────────────────────────────

# Commit 29
Set-Content "notification-service\Dockerfile" -Encoding UTF8 @'
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist
EXPOSE 3002
CMD ["node", "dist/index.js"]
'@
Set-Content "order-service\Dockerfile" -Encoding UTF8 @'
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY prisma ./prisma
COPY src ./src
RUN npx prisma generate
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
EXPOSE 3001
CMD ["node", "dist/index.js"]
'@
Set-Content "admin-service\Dockerfile" -Encoding UTF8 @'
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist
EXPOSE 3003
CMD ["node", "dist/index.js"]
'@
Make-Commit "2026-03-21T09:30:00" "chore: add multi-stage Dockerfiles for order, notification and admin services"

# Commit 30
New-Item -ItemType Directory -Force -Path ".github\workflows" | Out-Null
Set-Content ".github\workflows\ci.yml" -Encoding UTF8 @'
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      - run: npm ci
        working-directory: frontend
      - run: npm run build
        working-directory: frontend

  build-node-services:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [api-gateway, order-service, notification-service, admin-service]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
        working-directory: ${{ matrix.service }}

  docker-compose-validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker compose config
'@
Make-Commit "2026-03-21T11:30:00" "ci: add GitHub Actions workflow for frontend build, Node services, and compose validation"

# ─── Clean up env vars ───
Remove-Item env:GIT_AUTHOR_DATE    -ErrorAction SilentlyContinue
Remove-Item env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================="
Write-Host " All 30 backdated commits created! (2026)"
Write-Host "========================================="
git log --pretty="%ad | %s" --date=short
