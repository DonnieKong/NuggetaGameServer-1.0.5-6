$(document).ready(function () {
	
	$(window).resize(function () {
		paint();
	});
});

var paint = function() {
	var screenHeight = parseInt($(window).height());
	var screenWidth = parseInt($(window).width());

	var topHeight = parseInt($('.top').outerHeight());
	var pageHeight = screenHeight - topHeight;
	
	$('.page').css('height', pageHeight +  'px');
	
	var menuWidth = parseInt($('.page-menu').outerWidth());
	var pagePadding = parseInt($('.page-body').css('padding-left'));

	$('.page-body').css('width', (screenWidth - menuWidth - pagePadding*2) +  'px');
};

var outputJson = function(json, parent) {
	var pre = $('<pre class="json"></pre>');
	pre.html(json);
	
	$(parent).append(pre);
};

var syntaxHighlight = function(json) {
	var obj = JSON.parse(json);
	json = JSON.stringify(obj, undefined, 4);

    json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
        var cls = 'number';
        if (/^"/.test(match)) {
            if (/:$/.test(match)) {
                cls = 'key';
            } else {
                cls = 'string';
            }
        } else if (/true|false/.test(match)) {
            cls = 'boolean';
        } else if (/null/.test(match)) {
            cls = 'null';
        }
        return '<span class="' + cls + '">' + match + '</span>';
    });
};
