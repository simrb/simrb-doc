/*
 * == Example
 *
 * html 
 * 		#header.keeptop
 *			p note that the css of #header need to set {position: absolute; top: 0;}
 *			p and the color of #toTop { background: "colorwhatyouwant"; }
 *
 * js
 * 		== _js('system/js/jq.ontop.js')
 *
 */

$(".keeptop").before("<div id='toTop'><img src='/_assets/system/icons/totop.png'/></div>")
$("#toTop").css({
	"position" : "fixed",
	"bottom" : "5px",
	"right" : "5px",
	"display" : "none",
	"width" : "36px",
	"height" : "36px",
	"border-radius" : "6px",
	"cursor" : "pointer"
})

$("#toTop").click(function() {
	$('html, body').animate({scrollTop:0}, 100)
	return false;
});

$(window).scroll(function() {
    var aTop = $('.keeptop').height() - 10
    if($(this).scrollTop() > aTop){
		$('.keeptop').css('position', 'fixed')
		$('.keeptop').css('top', '0')
    }

    if ($(this).scrollTop()) {
        $('#toTop').fadeIn()
    } else {
        $('#toTop').fadeOut()
    }
});
