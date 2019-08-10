const express = require("express");
const app = express();
const port = 3000;

app.get("/map", (req, res) => {
  res.sendFile("./MazonAddon/addon-map.txt", { root: __dirname });
});

app.get("/rotations", (req, res) => {
  res.sendFile("./MazonAddon/rotation-map.txt", { root: __dirname });
});

app.get("/file/", (req, res) => {
  const filePath = req.query["file"];
  res.sendFile(`./${filePath}`, { root: __dirname });
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
