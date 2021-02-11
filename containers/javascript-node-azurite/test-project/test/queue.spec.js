'use strict';

const test = require('japa');
const { QueueServiceClient } = require("@azure/storage-queue");
const { v1: uuid} = require('uuid');
const STORAGE_CONNECTION_STRING = "UseDevelopmentStorage=true";

test.group('Queue testing', (group) => {
  // Creating container before running tests
  let queueServiceClient = null;

  group.before(async () => {
    // Note - Account connection string can only be used in node.
    queueServiceClient = QueueServiceClient.fromConnectionString(STORAGE_CONNECTION_STRING);
  });

  group.test('Create queue', async () => {
    // Create a new queue
    const queueName = `newqueue${uuid()}`;
    const queueClient = queueServiceClient.getQueueClient(queueName);
    const createQueueResponse = await queueClient.create();
    console.log(
      `Create queue ${queueName} successfully, service assigned request Id: ${createQueueResponse.requestId}`
    );
  });
});
