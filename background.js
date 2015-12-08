var url = "http://192.168.56.101:8000/";

chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
	switch(request.message) {
		case 'setText':
			console.debug("Received highlighted text:");
			console.debug(request.data);
			console.debug("Data from server:");
			loadXHR(request.data, decode);
		break;

		default:
			console.debug("default case listener");
		break;
	}
});

function loadXHR(tab, callback) {
  try {
    var xhr = new XMLHttpRequest();
	var url_params = url + "?tab=" + tab;
    xhr.open("GET", url_params);
    xhr.responseType = "arraybuffer";
    xhr.onerror = function() {console.debug("Network error.")};
    xhr.onload = function() {
      if (xhr.status === 200) callback(xhr.response);
      else console.debug("Loading error:" + xhr.statusText);
    };
    xhr.send();
  } catch (err) {console.debug(err.message)}
}

function decode(buffer) {
  console.debug("XHR Complete");
}