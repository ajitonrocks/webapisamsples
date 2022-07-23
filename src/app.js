'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello World');
});

const swaggerUi = require('swagger-ui-express'),
swaggerDocument = require('./swagger.json');
app.use(
  '/swagger',
  swaggerUi.serve, 
  swaggerUi.setup(swaggerDocument)
);
app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);