const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const sns = new SNSClient({
  region: process.env.AWS_REGION
});

exports.handler = async (event) => {
  console.log(`Received ${event.Records.length} SQS message(s)`);

  const batchItemFailures = [];

  for (const record of event.Records) {
    try {
      console.log("SQS MessageId:", record.messageId);

      const message = JSON.parse(record.body);

      console.log("Event:", JSON.stringify(message));

      if (message.eventType !== "ORDER_CREATED") {
        console.log("Ignoring event:", message.eventType);
        continue;
      }

      console.log("Order ID:", message.data.orderId);
      console.log("User ID:", message.data.userId);
      console.log("Total:", message.data.total);
      console.log("Status:", message.data.status);

      const snsMessage = {
        eventId: message.eventId,
        eventType: message.eventType,
        orderId: message.data.orderId,
        userId: message.data.userId,
        total: message.data.total,
        status: message.data.status,
        items: message.data.items
      };

      await sns.send(
        new PublishCommand({
          TopicArn: process.env.SNS_TOPIC_ARN,
          Subject: "ShopKart Order Created",
          Message: JSON.stringify(snsMessage)
        })
      );

      console.log(
        "ORDER_CREATED published to SNS successfully"
      );

    } catch (error) {
      console.error(
        "Failed to process message:",
        record.messageId,
        error
      );

      batchItemFailures.push({
        itemIdentifier: record.messageId
      });
    }
  }

  return {
    batchItemFailures
  };
};