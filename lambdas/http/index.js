const { v4: uuid } = require("uuid");
const { getCollection } = require("./db");

exports.handler = async (event) => {
  try {
    if (!event.body) return { statusCode: 400, body: "Missing body" };
    let payload = {};
    try { payload = JSON.parse(event.body); } catch(_) { return { statusCode: 400, body: "Invalid JSON" }; }
    const protocolId = String(payload.protocolId || "").trim();
    const message = String(payload.message || "").trim();
    if (!protocolId || !message) { return { statusCode: 400, body: "protocolId and message are required" }; }

    const col = await getCollection();
    const doc = { _id: uuid(), protocolId, message, source: "http", receivedAt: new Date().toISOString() };
    await col.insertOne(doc);

    return { statusCode: 201, headers: { "content-type": "application/json" }, body: JSON.stringify({ ok: true, id: doc._id }) };
  } catch (err) {
    console.error(err);
    return { statusCode: 500, body: "Internal error" };
  }
};
