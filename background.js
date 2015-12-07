chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
	switch(request.message) {
		case 'setText':
			console.debug("Received highlighted text:");
			console.debug(request.data);
			$.get("http://192.168.56.101:8000/", {"tab": request.data}, function(data) {console.debug(data);});
		break;

		default:
			console.debug("default case listener");
		break;
	}
});