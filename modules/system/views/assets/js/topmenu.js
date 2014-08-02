/* 
 * this is a menu that always keep itself on top of page
 *
 * == Example
 *
 * html 
 * 		#header.keeptop
 *			p note that the css of #header need to set by {position: absolute; top: 0;}
 *			p and the #toTop color set by { background: "colorwhatyouwant"; }
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

/* 
 * this is a dropdown menu
 *
 * == Example
 *
 * html
 * 		ul
 * 			li menu itme
 * 			li menu itme
 * 			li.dropdownitem this is a dropdown menu
 * 				ul.hide.dropdownlist
 * 					li sub menu
 * 					li sub menu
 *
 * js
 * 		== _js("system/js/dropdown")
 *
 */

$(".dropdownitem").hover(function(){
	$hide = $(this).find('.dropdownlist')
	$hide.css('position', 'absolute')
	$hide.css('top', 25)
	$hide.css('left', $(this).offset().left - 10)
	$hide.show()
}, function(){
	$hide = $(this).find('.dropdownlist')
	$hide.hide()
})

