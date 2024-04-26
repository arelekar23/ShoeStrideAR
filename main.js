// main.js
const express = require("express");
const SneaksAPI = require("sneaks-api");

const app = express();
const sneaks = new SneaksAPI();

app.get("/products", (req, res) => {
  sneaks.getProducts("", 100, (err, products) => {
    if (err) {
      res.status(500).json({ error: "Internal server error" });
      return;
    }
    res.json(products);
  });
});

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});
