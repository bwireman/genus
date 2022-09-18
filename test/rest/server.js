const http = require('http');
const e = require("../../types/E");

const requestListener = function (req, res) {
  let example_e = e.build_e({ a: "A", b: true, c: 1 });

  if (req.url === "/api/e") {
    if (req.method === "GET") {
      res.writeHead(200);
      res.end(JSON.stringify([example_e]));
    } else {
      res.end(JSON.stringify(example_e));
    }
  } else if (req.url === "/api/e/1") {
    res.writeHead(200);
    res.end(JSON.stringify(example_e));
  } else {
    res.writeHead(404);
    res.end(JSON.stringify({ error: "Oops" }));
  }
}

const server = http.createServer(requestListener);
server.listen(4000);