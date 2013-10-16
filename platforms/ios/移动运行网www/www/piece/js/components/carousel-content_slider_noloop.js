
define(['backbone', 'underscore', 'zepto', 'gmu','swipe'], function(Backbone, _, $, gmu,Swipe) {

    var Carousel = Backbone.View.extend({

        // viewNum {Number}: (可选, 默认:1) 可以同时看到几张图片
        // imgInit {Number}: (可选, 默认:2)初始加载几张图片
        // imgZoom {Boolean}: (可选, 默认:false)是否缩放图片,设为true时可以将超出边界的图片等比缩放
        // loop {Boolean}: (可选, 默认:false)设为true时,播放到最后一张时继续正向播放第一张(无缝滑动)，设为false则反向播放倒数第2张
        // springBackDis {Number}: (可选, 默认:15)滑动能够回弹的最大距离
        // autoPlay {Boolean}: ((可选, 默认:true)是否自动播放
        // autoPlayTime {Number}: (可选, 默认:4000ms)自动播放的间隔
        // animationTime {Number}: (可选, 默认:400ms)滑动动画时间
        // showArr {Boolean}: (可选, 默认:true)是否展示上一个下一个箭头  **Cube版本不需要显示
        // showDot {Boolean}: (可选, 默认:true)是否展示页码  **此处因为已经自行实现，所以不需要GMU的

        initialize: function() {
            var me = this;

            var dataViewNum = $(me.el).attr('data-viewNum');
            var dataImgInit = $(me.el).attr('data-imgInit');
            var dataImgZoom = $(me.el).attr('data-imgZoom');
            var dataLoop = $(me.el).attr('data-loop');
            var dataSpringBackDis = $(me.el).attr('data-springBackDis');
            var dataAutoPlay = $(me.el).attr('data-autoPlay');
            var dataAutoPlayTime = $(me.el).attr('data-autoPlayTime');
            var dataAnimationTime = $(me.el).attr('data-animationTime');
            var dataShowArr = $(me.el).attr('data-showArr');
            var dataShowDot = $(me.el).attr('data-showDot');


            var pagerEl = arguments[0].pagerEl;
            me.pagerEl=pagerEl;
            console.log('++++++++++')
            var titleCount = $($(pagerEl[0]).find('tr')[0]).children().length;
            console.log(titleCount)
            var thisCarousel =  Swipe(me.el,{
                continuous:false,
                callback:function(index,el){
                    console.log(arguments);
                    var offLeft = Math.floor($(pagerEl.find('td')[titleCount - index - 1]).offset().left);
                    $(pagerEl.find('.titlePointer')).animate({
                        left:offLeft
                    },300,'linear',function(){

                        $(pagerEl.find('td')).removeClass('activate');
                        $(pagerEl.find('td')[titleCount - index - 1]).addClass('activate');
                    });
                }
            });

            //  $(me.el).slider({
            //     viewNum: (dataViewNum === null ? 1 : dataViewNum),
            //     imgInit: (dataImgInit === null ? 2 : dataImgInit),
            //     imgZoom: (dataImgZoom === null || dataImgZoom === 'false' ? false : true),
            //     loop: (dataLoop === null || dataLoop === 'true' ? true : false),
            //     springBackDis: (dataSpringBackDis === null ? 15 : dataSpringBackDis),
            //     autoPlay: (dataAutoPlay === null || dataAutoPlay === 'true' ? true : false),
            //     autoPlayTime: (dataAutoPlayTime === null ? 4000 : dataAutoPlayTime),
            //     animationTime: (dataAnimationTime === null ? 400 : dataAnimationTime),
            //     showArr: (dataShowArr === null || dataShowArr === 'true' ? false : false),
            //     showDot: (dataShowDot === null || dataShowDot === 'true' ? false : false)
            // });


            var container = arguments[0].container;
            var carouselTitleEl = arguments[0].titleEl;
            // $(container).append(thisCarousel);

            setTimeout(function() {
                $(window).trigger('resize');

            }, 0);


            $(window).on('resize', carouselInit);

            function carouselInit(){
                // $(me.el).slider('_resize');
            }


            $(pagerEl.find('td')).removeClass('activate');
            $(pagerEl.find('td')[0]).addClass('activate');
            // $(pagerEl.find('td')).css({'background-color':'#ffffff'});
            // $(pagerEl.find('td')).css({'opacity':'0.3'});
            // $(pagerEl.find('td')[0]).css({'background-color':'#37c1f4'})
            // $(pagerEl.find('td')[0]).css({'opacity':'1.0'})


            // thisCarousel.on('slide',function(){

            //     var pageIndex = arguments[0].data;
            //     $(pagerEl.find('td')).removeClass('activate');
            //     $(pagerEl.find('td')[pageIndex]).addClass('activate');

            //     var offLeft = Math.floor($(pagerEl.find('td')[pageIndex]).offset().left);
            //     $(pagerEl.find('.titlePointer')).animate({
            //         left:offLeft
            //     },500,'linear');

            //     // pagerEl.find('td').css({'background-color':'#ffffff'});
            //     // pagerEl.find('td').css({'opacity':'0.3'});
            //     // $(pagerEl.find('td')[pageIndex]).css({'background-color':'#37c1f4'});
            //     // $(pagerEl.find('td')[pageIndex]).css({'opacity':'1.0'});
            //     carouselTitleEl.html($(pagerEl.find('td')[pageIndex]).html());
            // });
            
            var pCount = thisCarousel.getNumSlides();
            var windowWidth = $(window).width();
            console.log('windowWidth = '+windowWidth);
            console.log($(me.el)[0]);
            console.log($($(me.el)[0]).width());


            setTimeout(function() {
                // var contentWith = $($(me.el)[0]).width();
                // console.log('windowWidth = '+windowWidth);
                // console.log($($(me.el)[0]).width());
                // var contenContainer = $($(me.el)[0]).find('.swipe-wrap');
                // var contents = contenContainer.children();
                // contenContainer.css("width",contentWith*pCount);
                // for(m=0;m<pCount;m++){
                //     $(contents[m]).css("width",contentWith);
                // }
                $(window).trigger('resize')

            }, 100);

            for(k = 0; k < pCount; k++){
                console.log(windowWidth)
                var sliderIndex = k;
                $(pagerEl.find('td')[sliderIndex]).on('click',function(){
                    // sliderIndex $(this).index())
                    // $(me.el).slider('_move',$(this).index());
                    // alert(sliderIndex)
                    var pageIndex = pCount-1 - $(this).index();
                    var titleIndex = $(this).index();
                    var offLeft = Math.floor($(pagerEl.find('td')[$(this).index()]).offset().left);
                    thisCarousel.slide(pageIndex, 300);
                    $(pagerEl.find('.titlePointer')).animate({
                        left:offLeft
                    },300,'linear',function(){

                        $(pagerEl.find('td')).removeClass('activate');
                        $(pagerEl.find('td')[titleIndex]).addClass('activate');
                    });
                    // $(me.el).slider('_resize');
                })
            }
            $(pagerEl.find('td')[0]).trigger('click');


        
        },
        pagerEl:null,
        showByIndex: function(index){

            var me = this;
            var pagerEl = me.pagerEl;
            $(pagerEl.find('td')[index]).trigger('click');
        }
    }, {
        compile: function(elContext) {
            var me = this;
            // return _.map($(elContext).find(".slider"), function(tag) {
            //  var slider = new Slider({
            //      el: tag
            //  });
            //  return slider;
            // });
            return _.map($(elContext).find("carouselContent"), function(tag) {
                var container = document.createElement('div');
                var containerWidth = $(tag).css('width');
                var containerMargin = $(tag).css('margin');
                var contentHeight = $(tag).css('height');
                var swipeBackgroundColor = ($(tag).attr('background').length>0)? $(tag).attr('background'):'';
                var isShowPager = ($(tag).attr('showPager')=='true')? '':'none';
                var isShowHeader = ($(tag).attr('showHeader')=='true')? '':'none';
                var isPagerOnBottom = '';
                var isTitleOnBottom = '';
                var isTitleOnBottom_radius = '';

                var isPagerBorderRadius =false;
                if($(tag).attr('pagerOnBottom')=='true'){
                    isPagerOnBottom = 'bottom';
                    isTitleOnBottom = 'top';

                    isTitleOnBottom_radius = 
                    'border-top-left-radius: 9px;'+
                    'border-top-right-radius: 9px;';
                }else{
                    isPagerOnBottom = 'top';
                    isTitleOnBottom = 'bottom';

                    isTitleOnBottom_radius = 
                    'border-bottom-left-radius: 9px;'+
                    'border-bottom-right-radius: 9px;';
                }
          
                var carouselId = ($(tag).attr('id').length>0)? $(tag).attr('id') : 'myCarousel';
                $(container).attr('id',carouselId);
                $(container).attr('style','position:relative;'+
                                    'top:0;left:0;'+
                                    'width:'+containerWidth+';'+
                                    'margin:'+containerMargin+';'+
                                    'border:0px gray solid;'+
                                    'border-radius:0px;'+
                                    'margin-top:30px;'+
                                    'overflow:visible;'+
                                    'background:'+swipeBackgroundColor);

                var pager = '<table class="carouselContentPager"  border="0" cellpadding="0" cellspacing="0" '+
                                    'style="cursor:pointer;'+
                                    'width:100%;'+
                                    'height:3px;'+
                                    'position:'+
                                    'absolute;'+
                                    'z-index:'+
                                    '10;'+
                                    isPagerOnBottom+':-30px;'+
                                    'display:'+isShowPager+';';
                                if(isPagerBorderRadius){
                                    pager+=
                                    'border-bottom:1px solid;'+
                                    'border-top:1px solid;'+
                                    'border-'+isPagerOnBottom+'-left-radius: 9px;'+
                                    'border-'+isPagerOnBottom+'-right-radius: 9px;';
                                }
                                    pager+='">';
                
                var pagerPerWidth = Math.floor(100/$(tag).children().length);
                var childrenCount = $(tag).children().length;

                var pagerTD = '<tr>';
                var pagerTDEmpty ='';
                for (j = 0; j < childrenCount; j++){

                    var headerString = $($(tag).children()[j]).attr('title');
                    //alert(headerString)
                    pagerTD+='<td class="contentTitle" style="width:'+pagerPerWidth+'%;">'+headerString+'</td>';
                }
                pagerTD+='</tr>';
                pager 

                pager+=pagerTD+'<tr><td colspan="'+childrenCount+'"><div class="titlePointer"><div class="titlePointerArrow"> </div></div></td></tr></table>';
// 
                var pagerEl = $(pager)
                // var pager = 


                var attrs = tag.attributes;
                var finalTag = document.createElement('div');
                for(i=0; i< attrs.length; i++){
                    // finalTag.setAttribute(attrs[i].name, attrs[i].value);
                }
                $(finalTag).css({'width':'100%'});
                var swipContainer = document.createElement('div');
                $(swipContainer).addClass('swipe-wrap').css("height",contentHeight);

                // finalTag.innerHTML = tag.innerHTML;
                var contentLength = $(tag).children().length;
                var windowWidth = $(window).width();
                for(var j=0;j<contentLength;j++){
                    $(swipContainer).append( 
                        $($(tag).children()[contentLength-j-1])
                        .css({'width':windowWidth})
                     );
                }
                $(finalTag).append(swipContainer).addClass('swipe');

                console.log('-------------')

                var carouselContentTitleString='<div class="carouselContentTitle" style=""></div>';
                var carouselContentTitleEl=$(carouselContentTitleString);

                var carousel = new Carousel({
                    el: finalTag,
                    pagerEl: pagerEl,
                    container: container,
                    titleEl:carouselContentTitleEl
                });

                container.appendChild(finalTag);

                $(container).append(pagerEl);
                $(tag).replaceWith(container);
                var carouselContentStyle='<style type="text/css">'+
                    '.carouselContentTitle{ '+
                    'background-color: rgb(94, 135, 176);'+
                    isTitleOnBottom_radius+
                    'width:100%;'+
                    'height100px;'+
                    'position:absolute;'+
                    'left:0px;'+
                    'font-size:18px;'+
                    'text-align:center;'+
                    isTitleOnBottom+':0px;'+
                    'color: white;'+
                     'display:'+isShowHeader+';'+
                    'text-shadow: rgb(37, 79, 122) 0px -1px 1px;'+
                    'background-image: linear-gradient(rgb(83, 136, 200) 0%, rgb(47, 90, 136) 100%);'+
                '}'+

                '.swipe {'+
                    'overflow: hidden;'+
                    'visibility: hidden;'+
                    'position: relative;'+
                    'top:-10px;'+
                '}'+
                '.swipe-wrap {'+
                    'width:100%;'+
                    'overflow: hidden;'+
                    'position: relative;'+
                '}'+
                '.swipe-wrap > div {'+
                    'float:left;'+
                    'width:100%;'+
                    'position: relative;'+
                    'top:10px;'+
                    'z-index:10'+
                '}'+


                '.slider{ '+
                    'background-color: rgb(245, 245, 245);'+
                '}'+

                '.titlePointer{ '+
                    'position:absolute;'+
                    isPagerOnBottom+':10px;'+
                    'width:'+pagerPerWidth+'%;'+
                    'height:20px;'+
                    'text-align:center;'+
                    // 'background-color: green;'+
                '}'+

                '.slider{'+
                    'margin-top:10px;'+
                '}'+

                '.titlePointerArrow{'+
                    'border-left:10px solid transparent;'+
                    'border-right:10px solid transparent;'+
                    'border-top:10px solid transparent;'+
                    'border-bottom:10px solid rgb(246,246,246);'+
                    'margin:auto;'+
                    'font-size:0px;'+
                    'width:0px;'+
                    'height:0px;'+
                    // 'background-color:red;'+
                '}'+

                'table.carouselContentPager td.contentTitle{'+
                    'cursor:pointer;'+
                    'font-size:16px;text-align:center;'+
                    'color : white;'+//rgb(194,234,255)
                    // 'background-color:#ffffff;'+
                    'opacity : 0.5;'+
                '}'+
                'table.carouselContentPager td.activate{'+
                    //'background-color : #37c1f4;'+
                     // 'background-color: rgb(94, 135, 176);'+
                     'color:white;'+
                    'opacity : 1;'+
                '}'+
                'table.carouselContentPager td:first-child{'+
                    'border-'+isPagerOnBottom+'-left-radius: 9px;'+
                '}'+
                'table.carouselContentPager td:last-child{'+
                    'border-'+isPagerOnBottom+'-right-radius: 9px;'+
                '}'+
                '</style>';
                $(container).append(carouselContentTitleEl);
                $(container).append(carouselContentStyle);


                return carousel;
            });


        }

    });
    return Carousel;
});