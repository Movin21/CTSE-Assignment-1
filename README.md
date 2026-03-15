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
