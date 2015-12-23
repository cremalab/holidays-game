var http        = require('http');
var path        = require('path');
var express     = require('express');
var compression = require('compression');
var app         = express();
var env         = process.env.NODE_ENV = process.env.NODE_ENV || 'development';

app.use(compression())
app.use(express.static(process.cwd() + '/public'));

app.get('/*', function(req, res){
  var htmlPath = path.join(process.cwd(), 'public/index.html');
  res.sendFile(htmlPath);
});
var port = Number(process.env.PORT || 5000);
var server = http.createServer(app).listen(port, function(){
  console.log("Express server listening on port " + port);
});
