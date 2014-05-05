
// top_menu
$("#top_menu li").mouseover(function(){
	$(".sub_menu").hide()
	$(this).find(".sub_menu").show();

});
$("#top_menu li").mouseleave(function(){
	$(".sub_menu").hide()
	$(".focus1").next(".sub_menu").show();
});
