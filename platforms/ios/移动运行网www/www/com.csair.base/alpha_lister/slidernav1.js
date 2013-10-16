$.fn.listSliderNav = function(options,thisIscroll) {

	var alphaItemsEl = $($(this)[0]).find('.title');
	var alphaItems=[];
		for(var ij=0;ij<alphaItemsEl.length;ij++){
			alphaItems.push($(alphaItemsEl[ij]).attr('name'));
		}


	var defaults = {
		items: alphaItems,
		debug: false,
		height: null,
		arrows: true,
		pageIndex:0 
	};
	var opts = $.extend(defaults, options);

	var o = $.meta ? $.extend({}, opts, $$.data()) : opts;

	var listSlider = $(this);
	$(listSlider).addClass('listSlider');
	//$('.listSlider-content li:nth', listSlider).addClass('selected');

	$(listSlider).append('<div class="listSlider-nav"><ul></ul></div>');
	for (var i in o.items) $('.listSlider-nav ul', listSlider).append("<li><a alt='#" + o.items[i] + "'>" + o.items[i] + "</a></li>");
	var height = $('.listSlider-nav', listSlider).height();
	if (o.height) height = o.height;
	$('.listSlider-content, .listSlider-nav', listSlider).css('height', height);
	if (o.debug) $(listSlider).append('<div id="debug">Scroll Offset: <span>0</span></div>');
	var me = this
	$('.listSlider-content ul ul li a', listSlider).click(function(e){
		var target = $(listSlider).attr('target');
		$(target).val($(e.toElement).text());
		options.container.hide();
	});
	$('.listSlider-nav a', listSlider).click(sectionSelect);
	$('.listSlider-nav a', listSlider).mouseover(sectionSelect);

	function sectionSelect(event) {

		thisIscroll.scrollTo(0,0,0,0);
		$('.tip', listSlider).text($(event.toElement).text());
		$('.tip', listSlider).removeClass('show');
		window.clearTimeout(me.tipTimer);
		// window.clearTimeout(me.tipTimer2);
		$('.tip', listSlider).addClass('show');
		me.tipTimer = window.setTimeout(function (){
				$('.tip', listSlider).addClass('hide');
				me.tipTimer2 = window.setTimeout(function (){
					$('.tip', listSlider).removeClass('hide');
					$('.tip', listSlider).removeClass('show');
				},300);
		},1000);

		var target = $(this).attr('alt');
		
		var cOffset = $('.listSlider-content', listSlider).offset().top;
		var tOffset = $('.listSlider-content ' + target, listSlider).offset().top;
		var height = $('.listSlider-nav', listSlider).height();
		if (o.height) height = o.height;
		var pScroll = (tOffset - cOffset) - height / 8;
		$('.listSlider-content li').removeClass('selected');
		$(target).addClass('selected');
		
		var scrollTop = $('.listSlider-content').scrollTop();
		var actionTop = -1*(scrollTop+pScroll);

		defaults.pageIndex = Math.ceil((scrollTop+pScroll)/height);
		// console.log(defaults.pageIndex);

		thisIscroll.scrollTo(0,actionTop,300,0);

		// $('.listSlider-content',listSlider)[0].scrollTop = (scrollTop+pScroll);//.offset({'top':-1*(scrollTop+pScroll)});
		// $('.listSlider-content').css({
		// 	'scrollTop': (scrollTop+ pScroll) + 'px'
		// });
		if (o.debug) $('#debug span', listSlider).html(tOffset);
	}

	if (o.arrows) {
		$('.listSlider-nav', listSlider).css('top', '20px');
		$(listSlider).prepend('<div class="slide-up end"><span class="arrow up"></span></div>');
		$(listSlider).append('<div class="slide-down"><span class="arrow down"></span></div>');
		$('.slide-down', listSlider).click(function() {
			var scrollTop = $('.listSlider-content').scrollTop();
			var newScrollHeight= scrollTop + $('.listSlider-nav', listSlider).height();
			// $('.listSlider-content',listSlider)[0].scrollTop = newScrollHeight;

			var containerHeight = $('.listSlider-content', listSlider).find('ul').height();
			if((defaults.pageIndex+1)*newScrollHeight<containerHeight){
				defaults.pageIndex++;
			}
			thisIscroll.scrollToPage(0,defaults.pageIndex,300);
		
		});
		$('.slide-up', listSlider).click(function() {
			var scrollTop = $('.listSlider-content').scrollTop();
			var newScrollHeight= scrollTop - $('.listSlider-nav', listSlider).height();
			// $('.listSlider-content',listSlider)[0].scrollTop = newScrollHeight;


			if((defaults.pageIndex-1)>=0){
				defaults.pageIndex--;
			}
			thisIscroll.scrollToPage(0,defaults.pageIndex,300);

		});
	}
};