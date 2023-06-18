express = require('express');

app = express();

app.use(express.static(__dirname + '/../client/dist'));

app.listen(3001, () => {
    console.log('listening on port 3000!');
    }
);
