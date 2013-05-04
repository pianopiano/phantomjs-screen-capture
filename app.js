
/**
 * Module dependencies.
 */

var express = require('express')
,	routes = require('./routes')
,	http = require('http')
,	path = require('path')
,	phantom = require('node-phantom');
  
var app = express();

app.configure(function(){
 	app.set('port', process.env.PORT || 3000);
 	app.set('views', __dirname + '/views');
 	app.set('view engine', 'ejs');
 	app.use(express.favicon());
 	app.use(express.logger('dev'));
 	app.use(express.bodyParser());
 	app.use(express.methodOverride());
 	app.use(app.router);
 	app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
	app.use(express.errorHandler());
});

app.get('/', function(req, res){
 	res.render('index', { title: 'PhantomJS - Web Screen Capture' });
});

var server=require('http').createServer(app).listen(app.get('port'), function(){
	console.log("Express server listening on port " + app.get('port'));
});

var io=require('socket.io').listen(server);

io.sockets.on('connection',function(socket){
	socket.on('url',function(data){
		var fileName = data.name
		,	imgfile = 'public/images/output/'+fileName+'.png'
		,	fs = require('fs');
		
		phantom.create(function(err, ph) {
			if (err) throw err;
			ph.createPage(function(err, page) {
				if (err) throw err;
				page.open(data.url, function(err, status) {
					if (err) throw err;
					page.render(imgfile);
					page.close(function(){
						io.sockets.emit('image',imgfile.split('public')[1]);
						ph.exit(function(){
							//console.log('exit');
						});
					});
				});
			});
		});
	});
});
