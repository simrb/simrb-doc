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
