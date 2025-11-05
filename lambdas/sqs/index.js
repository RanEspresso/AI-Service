const { v4: uuid } = require("uuid");
const { getCollection } = require("./db");

exports.handler = async (event) => {
  const failures = [];
  const col = await getCollection();

  await Promise.all((event.Records || []).map(async (r) => {
    try {
      const body = JSON.parse(r.body || "{}");
      const protocolId = String(body.protocolId || "").trim();
      const message = String(body.message || "").trim();
      if (!protocolId || !message) throw new Error("Bad message");
      await col.insertOne({ _id: uuid(), protocolId, message, source: "sqs", receivedAt: new Date().toISOString() });
    } catch (e) {
      console.error("Failed for", r.messageId, e);
      failures.push({ itemIdentifier: r.messageId });
    }
  }));

  return { batchItemFailures: failures };
};
