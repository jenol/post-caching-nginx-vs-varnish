const express = require('express');

const app = express();

app.post('/', (req, res) => {
    let raw = '';
    req.on('data', function(d) {
        raw += d;
    });
    req.on('end', function() {
        res.end(raw.split("").reverse().join(""));
    });
});


app.get('/', (req, res) => {
    res.end('Only POST requests are accepted!');
});

(async () => {
    await app.listen(3000);
    console.log("Server is running on port: 3000")
})();

