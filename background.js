var url = "http://192.168.56.101:8000/";
var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
var source;

chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
	switch(request.message) {
		case 'setText':
			console.debug("Received highlighted text:");
			console.debug(request.data);
			console.debug("Data from server:");
			loadXHR(request.data);
			source.start(0);
		break;

		default:
			console.debug("default case listener");
		break;
	}
});

function loadXHR(tab) {
  try {
    source = audioCtx.createBufferSource();
    var xhr = new XMLHttpRequest();
	var url_params = url + "?tab=" + tab;
    xhr.open("GET", url_params);
    xhr.responseType = "arraybuffer";
    xhr.onerror = function() {console.debug("Network error.")};
    xhr.onload = function() {
		var audioData = xhr.response;
		audioCtx.decodeAudioData(audioData, function(buffer) {
			source.buffer = buffer;
			source.connect(audioCtx.destination);
			source.loop = false;
			},
		function(e){"Error with decoding audio data" + e.err});
	}
    xhr.send();
  } catch (err) {console.debug(err.message)}
}