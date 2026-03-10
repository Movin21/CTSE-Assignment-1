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

// ─── Get all orders (optionally filtered by userId) ────────────────────────
app.get("/api/orders", async (req: Request, res: Response) => {
  try {
    const { userId } = req.query;
    const whereClause = userId ? { userId: String(userId) } : {};
    const orders = await prisma.order.findMany({
      where: whereClause,
      orderBy: { createdAt: "desc" },
    });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch orders" });
  }
});

// ─── Get ALL orders (admin) ────────────────────────────────────────────────
app.get("/api/orders/all", async (_req: Request, res: Response) => {
  try {
    const orders = await prisma.order.findMany({
      orderBy: { createdAt: "desc" },
    });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch orders" });
  }
});
