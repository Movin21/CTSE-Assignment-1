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
