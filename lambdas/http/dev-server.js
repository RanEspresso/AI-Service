const http = require("http");
const handler = require("./index").handler;

const server = http.createServer(async (req, res) => {
    const chunks = [];
    req.on("data", (c) => chunks.push(c));
    req.on("end", async () => {
        const body = Buffer.concat(chunks).toString("utf8");

        // Craft a minimal API Gateway v2 event for our Lambda handler
        const event = {
            version: "2.0",
            requestContext: {
                http: { method: req.method, path: req.url.split("?")[0] }
            },
            body,
            isBase64Encoded: false,
        };

        try {
            const result = await handler(event);
            res.statusCode = result.statusCode || 200;
            if (result.headers) {
                Object.entries(result.headers).forEach(([k, v]) => res.setHeader(k, v));
            }
            res.end(result.body || "");
        } catch (e) {
            console.error(e);
            res.statusCode = 500;
            res.end("Local dev error");
        }
    });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Local dev HTTP listening on http://localhost:${PORT}`);
});
