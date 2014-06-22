
$("#header").before("<div id='toTop'><img src='/_assets/public/icons/totop.png'/></div>")
$("#toTop").css({
	"position" : "fixed",
	"bottom" : "5px",
	"right" : "5px",
	"display" : "none",
	"cursor" : "pointer"
})

$("#toTop").click(function() {
	$('html, body').animate({scrollTop:0}, 100)
	return false;
});

$(window).scroll(function() {
    var aTop = $('#header').height() - 10
    if($(this).scrollTop() > aTop){
		$('#header').css('position', 'fixed')
		$('#header').css('top', '0')
    }

    if ($(this).scrollTop()) {
        $('#toTop').fadeIn()
    } else {
        $('#toTop').fadeOut()
    }
});
