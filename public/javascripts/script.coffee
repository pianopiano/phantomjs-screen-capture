$ ->
	socket = io.connect 'http://localhost:3000'
	$('.btn').on 'click', ->
		val = $('#siteName').val()
		d = new Date()
		name = d.getFullYear()+''+d.getMonth()+1+''+d.getDate()+''+d.getDay()+''+d.getHours()+''+d.getMinutes()+''+d.getSeconds()
		socket.emit 'url', {url:val, name: name}
		$('#loadImage').empty().append '<img id="loadImg" src="/images/ajax-loader.gif" />'
		return false
		
	socket.on 'image', (data) ->
		$('#loadImage').empty().append '<img id="loadImg" src="'+data+'" />'
@
