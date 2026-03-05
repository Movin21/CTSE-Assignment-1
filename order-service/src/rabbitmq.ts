import * as amqp from 'amqplib';

const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://guest:guest@rabbitmq:5672';
const QUEUE_NAME = 'order_events';

let channel: amqp.Channel | null = null;

export async function connectRabbitMQ(): Promise<void> {
    const connection = await amqp.connect(RABBITMQ_URL);
    channel = await connection.createChannel();
    await channel.assertQueue(QUEUE_NAME, { durable: true });
    console.log('Connected to RabbitMQ');
}

export function publishOrderEvent(order: object): boolean {
    if (!channel) {
        console.error('RabbitMQ channel not initialized');
        return false;
    }
    const message = JSON.stringify({ event: 'order.created', data: order, timestamp: new Date().toISOString() });
    return channel.sendToQueue(QUEUE_NAME, Buffer.from(message), { persistent: true });
}
