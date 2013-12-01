// Application.js Manifest
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

var ready = function() {

	// Initialize Foundation
	$(document).foundation();

};

// Run on natural page load...
$(document).ready(ready);
// ...and on Turbolinks reload
$(document).on('page:load', ready);
