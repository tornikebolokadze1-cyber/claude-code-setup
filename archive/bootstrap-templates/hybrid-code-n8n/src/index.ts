import express from "express";
import dotenv from "dotenv";
import { webhookRouter } from "./routes/webhook";
import { healthRouter } from "./routes/health";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, _res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// Routes
app.use("/health", healthRouter);
app.use("/api/webhooks", webhookRouter);

// Root
app.get("/", (_req, res) => {
  res.json({
    name: process.env.APP_NAME || "hybrid-app",
    status: "running",
    endpoints: {
      health: "/health",
      webhooks: "/api/webhooks/n8n",
    },
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`n8n instance: ${process.env.N8N_INSTANCE_URL || "not configured"}`);
  console.log(`Webhook endpoint: http://localhost:${PORT}/api/webhooks/n8n`);
});

export default app;
