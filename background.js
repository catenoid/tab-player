// hello
chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
	switch(request.message) {
		case 'setText':
			console.debug("setText listener");
		break;

		default:
			console.debug("default case listener");
		break;
	}
});