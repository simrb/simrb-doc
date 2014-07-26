/*
 * == Example
 *
 * html
 *		div class="ly_shoxbox"
 *			img src=""
 * 
 * js
 * 		== _js("system/js/showbox.js")
 *
 */


(function($){
	var methods = {
		init : function(options) {
			return this.each(function(){
				//default value
				var options = $.extend({
					show_box_bg : {
						width : $(window).width(),
						height : $(window).height(),
						background : '#E3EEEB',
						padding : '10px',
						filter : 'alpha(opacity=70',
						'-moz-opacity' : '0.7',
						opacity : '0.7',
					},
					show_box_panel : {
						padding : '5px',
						background : 'white',
						position : 'absolute',
						margin : '0 auto',
					},
				}, options);
				$(this).data('ly_showbox', options);

				//default method
				$(this).ly_showbox('setup', options);
			});
		},

		setup : function(options) {
			return this.each(function(){

				$(this).click(function(){
					$("#wrap").before("<div class='show_box'><div class='show_box_bg'/><div class='show_box_panel'>" + $(this).html() + "</div></div>");

					$('.show_box').css('position', 'absolute');
					$('.show_box').css('z-index', 111);

					$('.show_box_bg').css(options.show_box_bg);
					$('.show_box_panel').css(options.show_box_panel);

					var top = ($(window).height() / 2) - ($('.show_box').find('img').height() / 2);
					var left = ($(window).width() / 2) - ($('.show_box').find('img').width() / 2);
					$('.show_box_panel').css('top', top);
					$('.show_box_panel').css('left', left);

					$(document).scroll(function(){
						var top = ($(window).height() / 2) - ($('.show_box').find('img').height() / 2);
						var scrollTop = $(window).scrollTop();
						$('.show_box_panel').css('top', top + scrollTop);
					});

					$(".show_box").click(function(){
						$(this).remove();
					})
				//click end
				});

			});
		}
	};

	$.fn.ly_showbox = function(method) {
		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || ! method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist on plugins of jQeury');
		}
	};
})(jQuery);

$('.ly_showbox').ly_showbox();

