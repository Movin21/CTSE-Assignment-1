import express, { Request, Response } from "express";
import cors from "cors";
import morgan from "morgan";
import { PrismaClient } from "@prisma/client";
import { connectRabbitMQ, publishOrderEvent } from "./rabbitmq";

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.ORDER_PORT || process.env.PORT || 3001;
const PRODUCT_SERVICE_URL =
  process.env.PRODUCT_SERVICE_URL || "http://product-service:8082";

// ─── Middleware ────────────────────────────────────────────────────────────
app.use(cors());
app.use(morgan("combined"));
app.use(express.json());

// ─── Health ────────────────────────────────────────────────────────────────
app.get(["/health", "/api/orders/health"], (_req: Request, res: Response) => {
  res.json({
    status: "UP",
    service: "order-service",
    timestamp: new Date().toISOString(),
  });
});
