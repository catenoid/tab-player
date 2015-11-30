console.debug("I loaded");

$( document ).mouseup(function() {
		console.debug("Mouse up Event");
		var sel = window.getSelection().toString();
		if(sel.length) {
			console.debug(sel);
			chrome.runtime.sendMessage({'message':'setText','data': sel}, function(response){});
			}
	});