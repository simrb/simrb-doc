/*
 * == Example
 *
 * html
 * 		div class="linyu_select"
 *
 * js
 * 		== _js("system/js/select.js")
 *
 */


//display a menu , return the name be chosen with mouse
function linyu_select(data, $this, options) {
	var menu_text = '';
	$.each(data, function(key, val){
		menu_text += '<li key="' + key + '">' + val + '</li>';
	});
	menu_text = '<ul class="linyu_select">' + menu_text + '</ul>';

	//init
	if ($this.next('ul').hasClass('linyu_select')) {
		$this.next('ul.linyu_select').show();
	} else {
		$this.after(menu_text);
		$linyu_select = $this.next('ul.linyu_select');

		//ul style
		$.each(options.ul_css, function(key, val){
			$linyu_select.css(key, val);
		});

		//ul style and event
		$.each(options.li_css, function(key, val){
			$linyu_select.find('li').css(key, val);
		});
		$linyu_select.find('li').hover(function(){
			$(this).css('background', options.li_bg);
		}, function(){
			$(this).css('background', '');
		});

		$linyu_select.find('li').click(function(){
			$linyu_select.hide();
			$this.find('option[value="' + $(this).attr('key') + '"]').attr('selected', 'selected');
		});
		
		$linyu_select.mouseleave(function(){
			$(this).hide();
		});
	}

}

(function($){
	var methods = {
		init : function(options) {
			return this.each(function(){
				//default value
				var options = $.extend({
					ul_css : {
						top : $(this).offset().top,
						left : $(this).offset().left,
						width : $(this).width(),
						position : 'absolute',
						background : 'white',
						border : '1px solid black',
						padding : '5px',
					},
					li_css : {
						cursor : 'pointer',
						padding : '3px',
					},
					li_bg : '#DADDE2',
				}, options);
				$(this).data('linyu_select', options);

				//default method
				$(this).linyu_select('select', options);
			});
		},

		//select
		select : function(options) {
			return this.each(function(){

				$(this).mouseover(function(){
					var option_json = {};
					$(this).find('option').each(function(index){
						if ($(this).text() != 'undefined') {
							option_json[$(this).attr('value')] = $(this).text();
						} 
					});
					linyu_select(option_json, $(this), options);
				});

			});
		}
	};

	$.fn.linyu_select = function(method) {
		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || ! method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist on plugins of jQeury');
		}
	};
})(jQuery);

$('.linyu_select').linyu_select();

