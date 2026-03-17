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
