express = require('express')
routes = require('./routes')
http = require('http')
path = require('path')
phantom = require('node-phantom')
app = express()
app.configure ->
	app.set 'port', process.env.PORT || 3000
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'ejs'
	app.use express.favicon()
	app.use express.logger('dev')
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use app.router
	app.use express.static path.join __dirname, 'public'
	
app.configure 'development', ->
	app.use express.errorHandler()
	
app.get '/', (req, res) ->
	res.render 'index', {title: 'PhantomJS - Web Screen Capture'}
	
server=require('http').createServer(app).listen app.get('port'), ->
	console.log("Express server listening on port " + app.get('port'))

io = require('socket.io').listen server
io.sockets.on 'connection', (socket) ->
	socket.on 'url', (data) ->
		fileName = data.name
		imgfile = 'public/images/output/'+fileName+'.png'
		fs = require 'fs'
		
		phantom.create (err, ph) ->
			if err then throw err
			ph.createPage (err, page) ->
				if err then throw err
				page.open data.url, (err, status) ->
					if err then throw err
					page.render imgfile
					page.close ->
						io.sockets.emit 'image', imgfile.split('public')[1]
						ph.exit ->
							console.log 'exit'
