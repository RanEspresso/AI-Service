const { MongoClient } = require("mongodb");
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");

let client = null;
let uri = null;

async function getMongoUri() {
  if (uri) return uri;
  const secretName = process.env.MONGODB_SECRET_NAME;
  if (!secretName) throw new Error("MONGODB_SECRET_NAME not set");
  const sm = new SecretsManagerClient({});
  const resp = await sm.send(new GetSecretValueCommand({ SecretId: secretName }));
  uri = resp.SecretString;
  if (!uri) throw new Error("Secret has no string value");
  return uri;
}

async function getCollection() {
  const mongoUri = await getMongoUri();
  if (!client) {
    client = new MongoClient(mongoUri, { maxPoolSize: 5 });
    await client.connect();
  }
  const dbName = process.env.MONGODB_DB || "app";
  return client.db(dbName).collection("protocol_logs");
}

module.exports = { getCollection };
