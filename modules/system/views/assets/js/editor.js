/*
 * == Example
 *
 * html
 * 		input class="linyu_textarea" type="textarea"
 *
 * js
 * 		== _js("system/js/editor.js")
 *
 * css
 *		== _css("system/css/editor.css")
 *
 */

function linyu_show_msg(data) {
	$('#msg').text(data);
	setTimeout(function(){ $('#msg').text(''); }, 3000);
}

function linyu_insert_to_textarea(opt) {

	var textarea = $('.editor').data('textarea');
	var before = opt.before != undefined ? opt.before : '';
	var after = opt.after != undefined ? opt.after : '';
	var replace = opt.replace != undefined ? opt.replace : '';

	if (opt.html_type == 'img') {
		replace = '![' + opt.img_name + '](' + opt.img_link + ')';
	}

	if (before != '' || after != '' || replace != '') {
		var len = textarea.val().length;
		var start = textarea[0].selectionStart;
		var end = textarea[0].selectionEnd;
		var select_text = replace != '' ? replace : textarea.val().substring(start, end);
		var replace_text = before + select_text + after;
		textarea.val(textarea.val().substring(0, start) + replace_text + textarea.val().substring(end, len));
	}

}

(function($){

	var methods = {
		init : function(options) {
			return this.each(function(){
				var config = $.extend({
					parser_path : '/_file/preview',
					folder_path : '/_file/type/all',
					picture_path : '/_file/type/image',
					upload_path : '/_file/upload',
					icon_path : '/icons/',
					file_path : '/_file/get/',
					file_type : ['image/jpeg', 'image/gif', 'image/png'],
					file_size : 300000,
					toolbar : [
						{name : 'h1', key : '1', before : '# ', title :'Header 1'},
						{name : 'h2', key : '2', before : '## ', title :'Header 2'},
						{name : 'h3', key : '3', before : '### ', title :'Header 3', separator : '|'},

						{name : 'bold', key : 'B', before : '**', after : '**'},
						{name : 'italic', key : 'I', before : "_", after : "_", separator : '|'},

						{name : 'ol', before : '+ '},
						{name : 'ul', before : '- ', separator : '|'},

						{name : 'quotes', before : '-------\n', after : '\n-------\n'},
						{name : 'code', before : '```\n', after : '\n```', separator : '|'},

						{name : 'picture', class : 'dropmenu', event : 'create_event_picture'},
						{name : 'link', key : 'L', before : '[name]', after : '(link)'},
						{name : 'folder', class : 'dropmenu', event : 'create_event_folder'},
					]
				}, options);

				$(this).linyu_editor('setup', config);
			});
		},

		setup : function(config) {
			return this.each(function(){

				//select the textarea to update rich text editor
				var textarea = $(this);
				textarea.wrap('<div class="editor" style="clear:both;" />');

				//add a toolbar to editor
				$('.editor').before('<div class="toolbar" />');

				//initialize the toolbar
				var toolbar = "";
				$.each(config.toolbar, function(index, item){

					//set the toolbar index, attr, class, title, key ...
					//event listener need to get the value from json with this index
					toolbar += '<a index="' + index + '"';

					if (item.key != undefined) {
						toolbar += ' accessKey="' + item.key + '"';
					}
					if (item.title != undefined) {
						toolbar += ' title="' + item.title + '"';
					} else {
						toolbar += ' title="' + item.name + '"';
					}

					toolbar += ' class="' + item.name;
					if (item.class != undefined) {
						toolbar += ' ' + item.class;
					}
					toolbar += '">' + item.name + '</a>';

					if (item.separator != undefined) {
						toolbar += '<a style="background-image:url(' + config.icon_path + 'separator.png)">' + item.separator + '</a>';
					}


				});

				//setup the toolbar
				$('.toolbar').append(toolbar);
				$('.toolbar a').each(function(index){
					var index = $(this).attr('index');
					if (index) {
						$(this).css('background-image', 'url("' + config.icon_path + config.toolbar[index].name + '.png")');
					}
				});

				$('.editor').data('textarea', textarea);
				$('.editor').data('config', config);
				$(this).linyu_editor('create_event', config);

			});
		},

		//add the event to each item of toolbar
		create_event : function(config) {
			return $(this).each(function(){

				$.each(config.toolbar, function(index, item){
					if (item.event == undefined) {
						$('.toolbar .' + item.name).click(function(){
							linyu_insert_to_textarea(item);
						});
					} else if (item.event == 'create_event_folder') {
						$('.toolbar .' + item.name).linyu_editor('create_event_folder', config);
					} else if (item.event == 'create_event_picture') {
						$('.toolbar .' + item.name).linyu_editor('create_event_picture', config);
					}
				});

			});
		},

		create_event_folder : function(config) {
			return $(this).each(function(){

				//initialize the folder item
				var folder = '<div class="folder_menu">'
				//form
				folder += '<form class="folder_upload clear"><input type="file" name="upload" /></form><span class="folder_close" /><span class="folder_submit" />';
				//progressbar
				folder += '<div class="folder_progressbar"><div class="folder_subprogressbar">0 %</div></div>';
				//view
				folder += '<div class="folder_view"></div>';
				folder += '</div>';

				//folder item event
				var create_folder_menu = false;
				$('.folder').click(function(){

					if (create_folder_menu === true) {
						$('.folder_menu').show();
					} else {

						//initialize folder dropmenu
						$(this).after(folder);
						var folder_menu = $('.folder_menu');
						folder_menu.css('top', $(this).offset().top + 15);
						folder_menu.css('left', $(this).offset().left);

						//add closed event
						$('.folder_close').click(function(){
							$('.folder_menu').hide();
						});

						//add changed event
						$('.folder_upload').change(function(){
							$('.folder_subprogressbar').text('0 %');
							$('.folder_subprogressbar').css('background-color', '');
						});

						//add view event
						$(this).linyu_editor('folder_view', config);

						//add validation function to form
						var linyu_upload_validation_error = '';
						$('.folder_upload :file').change(function(){
							var file = this.files[0];
							if ($.inArray(file.type, config.file_type) == -1) {
								linyu_upload_validation_error = 'the file must be (' + config.file_type.join(',') + '), but rather is ' + file.type;
							}
							if (file.size > config.file_size) {
								linyu_upload_validation_error = 'The file size ' + file.size + ' is not better than ' + config.file_size;
							}
						});

						//add uploading event
						$('.folder_submit').click(function(){
							if (linyu_upload_validation_error != '') {
								linyu_show_msg(linyu_upload_validation_error);
								return false;
							}

							var formData = new FormData($('.folder_upload')[0]);

							$.ajax({

								url : config.upload_path,
								type : 'post',

								xhr : function() {
									myxhr = $.ajaxSettings.xhr();
									if (myxhr.upload) {
										myxhr.upload.addEventListener('progress', function(e){
											var done = e.position || e.loaded, total = e.totalSize || e.total;
											var progressbar = 'uploading ... ' + (Math.floor(done/total*1000)/10) + ' %';
											$('.folder_subprogressbar').text(progressbar);
										}, false);
									}
									return myxhr;
								},

								success : function(data) {
									//update progressbar
									$('.folder_subprogressbar').text('100 %');
									$('.folder_subprogressbar').css('background-color', 'yellow');

									//show message
									linyu_show_msg(data);

									//update folder view
									$(this).linyu_editor('folder_view', config);
								},

								error : function(xhr, status, err) {
									console.log(xhr.responseText);
									console.log(status);
									console.log(err);
								},

								data : formData,
								cache : false,
								contentType : false,
								processData : false

							}, 'join');

							return false;

						});
						create_folder_menu = true;
						//initialize folder dropmenu ---- end
					}

				});

			///-- setup complete


			});
		},


		folder_view : function(config) {
			return $(this).each(function(){

				var folder_view = '';
				$.getJSON(config.folder_path, function(data){
					if (data != undefined) {
						var datas = [];
						datas.push('<tr><td>name</td><td>type</td></tr>');
						$.each(data, function(index, item){
							var type = item.type.split('/')
							datas.push('<tr><td class="name" href="' + config.file_path + item.fid + '">' + item.name + '</td><td class="type">' + item.type + '</td></tr>');
						});
						$('.folder_view').html('<table>' + datas.join('') + '</table>');

						//add event
						$('.folder_view .name').click(function(){
							linyu_insert_to_textarea({replace : '[' + $(this).text() + '](' + $(this).attr('href') + ')'});
						});
					} else {
						$('.folder_view').html('<p>No data found.</p>');
					}
				});

			});
		},

		create_event_picture : function(config) {
			return $(this).each(function(){
				
					var pictures = '<div class="picture_view" />';
					$('.picture').after(pictures);
					var picture_offset = false;

					//add view
					$(this).linyu_editor('picture_view', config);

					//add event
					$('.picture').mouseenter(function(){
						$('.picture_view').show();
						if (picture_offset == false) {
							$('.picture_view').css('top', $(this).offset().top + 15);
							$('.picture_view').css('left', $(this).offset().left);
							picture_offset = true;
						}
					});
					$('.picture_view').mouseleave(function(){
						$('.picture_view').hide();
					});

					$('.picture').click(function(){
						$(this).linyu_editor('picture_view', config);
						//$('.picture_view').show();
					});

			});
		},

		picture_view : function(config) {
			return $(this).each(function(){

				var picture_view = '';
				$.getJSON(config.picture_path, function(data){
					if (data != undefined) {
						var datas = [];
						$.each(data, function(index, item){
							var type = item.type.split('/')
							datas.push('<li><img src="' + config.file_path + item.fid + '" alt="' + item.name + '" title="' + item.name + '"  /></li>');
						});
						$('.picture_view').html('<ul>' + datas.join('') + '</ul>');
						$('.picture_view li img').click(function(){
							linyu_insert_to_textarea({html_type : 'img', img_link : $(this).attr('src'), img_name : $(this).attr('alt')});
						});
					} else {
						$('.picture_view').html('<p>No data found.</p>');
					}
				});

			});
		},

	
	};


	$.fn.linyu_editor = function(method) {
		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || ! method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist on plugins of jQeury');
		}
	};
})(jQuery);

// auto inject the js link
$('.linyu_textarea').linyu_editor();

