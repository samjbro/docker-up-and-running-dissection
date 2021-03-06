var express = require('express');

// Constants
var DEFAULT_PORT = 8080;
var PORT = process.env.PORT || DEFAULT_PORT;
var DEFAULT_WHO = "World";
var WHO = process.env.WHO || DEFAULT_WHO;

// App
var app = express();
app.get('/', function (req, res) {
    res.send('Hello ' + WHO + '\n');
});

app.listen(PORT);
console.log('Running on http://localhost:' + PORT);