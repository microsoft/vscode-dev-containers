'use strict';

const test = require('japa');
const { BlobServiceClient } = require('@azure/storage-blob');
const { v1: uuid} = require('uuid');
const AZURE_STORAGE_CONNECTION_STRING = "UseDevelopmentStorage=true";

test.group('Blob storage testing', (group) => {
  // Creating container before running tests
  let containerClient = null;

  group.before(async () => {
    const blobServiceClient = BlobServiceClient.fromConnectionString(AZURE_STORAGE_CONNECTION_STRING);

    // Create a unique name for the container
    const containerName = 'quickstart' + uuid();

    // Get a reference to a container
    containerClient = blobServiceClient.getContainerClient(containerName);

    // Create the container
    const createContainerResponse = await containerClient.create();
    console.log("Container was created successfully. requestId: ", createContainerResponse.requestId);
  });

  group.test('Create blob file', async () => {
    // Create a unique name for the blob
    const blobName = 'quickstart' + uuid() + '.txt';

    // Get a block blob client
    const blockBlobClient = containerClient.getBlockBlobClient(blobName);

    console.log('\nUploading to Azure storage as blob:\n\t', blobName);

    // Upload data to the blob
    const data = 'Hello, World!';
    const uploadBlobResponse = await blockBlobClient.upload(data, data.length);
    console.log("Blob was uploaded successfully. requestId: ", uploadBlobResponse.requestId);
  });
});
