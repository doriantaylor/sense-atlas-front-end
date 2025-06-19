(function () {
    let openDetails = function (fragment) {
	if (fragment[0] == '#') fragment = fragment.substring(1);

	let elem = document.getElementById(fragment);
	if (elem && elem.localName === 'details') {
	    console.log(`opening details ${elem.id}`);
	    elem.open = true;
	}
    };

    let fragmentLoader = function (e) {
        console.log(window.location);

        // this is weird but this is what you need to do
        if (window.location.hash) {
            console.log('forcing scroll to ' + window.location.hash);
            window.location.hash = window.location.hash;
	    openDetails(window.location.hash);
        }
        return true;
    };

    let hashChange = function (e) {
	let match = /^#(.*)/.exec(window.location.hash);
	if (match) openDetails(match[1]);
    };

    window.addEventListener('load', fragmentLoader, false);
    window.addEventListener('hashchange', hashChange, false);
})();

function sendMail (domain, localPart, subject) {
    let out = 'mailto:' + localPart + String.fromCharCode(64) + domain;
    if (subject) out += '?subject=' + encodeURI(subject);
    window.location = out;
}
