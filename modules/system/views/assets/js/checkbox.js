/*
 * == Example
 *
 * html
 * 		table.checkall
 * 			input.checkall-switch type="checkbox"
 * 			input type="checkbox"
 * 			input type="checkbox"
 *
 * js
 * 		== _js("system/js/view.js")
 */

$('.checkall-switch').click(function(){
	$(this).parents('.checkall').find("input:checkbox").each(function(){
		var cba = $(this).attr('checked')
		if ( cba == undefined ) {
			$(this).attr('checked', 'checked')
		} else {
			$(this).removeAttr('checked')
		}
	})
})
