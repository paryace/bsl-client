
define(['backbone', 'underscore', 'zepto', 'gmu'], function(Backbone, _, $, gmu) {

    var RangeMenu = Backbone.View.extend({

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
        events: {
            "click .bottomRangeMenu": "onItemSelect"
        },

        initialize: function(args) {
            var me = this;

            $(args.el).find('.bottomRangeButton').click(function(){
                $(args.el).toggleClass('expand');
            });

        
        },
        shouldPreventListEvent: function(nodeName) {
            if (nodeName != 'TEXTAREA' && nodeName != 'INPUT' && nodeName != 'SELECT') return true;
            else return false;
        },
        onItemSelect: function(e){
            var target = e.currentTarget;
            var data = $(target).attr('data');
            var index = $(target).index();

            var nodeName = e.toElement != null ? e.toElement.nodeName : e.target.nodeName;
            if (this.shouldPreventListEvent(nodeName)) {
                this.trigger("RangeMenu:select", this, data, index,target);
                //list, record(include event)
                this.trigger("select", this, {
                    data: data,
                    index: index,
                    event: e,
                    target:target
                });
            }
        }
    }, {
        compile: function(elContext) {
            var me = this;

            return _.map($(elContext).find("rangeMenu"), function(tag) {
                var menuAngle = $(tag).attr('angle');
                if(!menuAngle||!parseInt(menuAngle)){
                    menuAngle=180;
                }

                var scaleY = 0.7;


                var menuRadius = $(tag).attr('radius')?$(tag).attr('radius'):150;

                var menuId = $(tag).attr('id');
                var menuName = $(tag).attr('name');
                if(menuId.length>0){menuId=' id="'+menuId+'" '}
                var fullAngle = (Math.PI)*(menuAngle/180);
                var restAngle = Math.PI - fullAngle;
                var items = $(tag).find('item');

                var itemString='';
                var styleString='<style type="text/css">';
                var perAngle = (fullAngle/(items.length-1));
                var menuitems=[];
                for(var i=0;i<items.length;i++){
                    var itemEl = $(items[i]).html();
                    var itemData = $(items[i]).attr('data');
                    var itemId = ($(items[i]).attr('id')&&$(items[i]).attr('id').length>0)?$(items[i]).attr('id'):null;
                    menuitems.push({
                        id:itemId,
                        el:itemEl,
                        data:itemData,
                        elContext:elContext,
                        that:me
                    });

                    itemString+='<div class="bottomRangeMenu" ';
                    if(menuitems[i].id){
                        itemString+=' id="'+ menuitems[i].id +'" ';
                    }
                    itemString+=' data="'+ menuitems[i].data +'" >';
                    itemString+= menuitems[i].el;
                    itemString+='</div>';


                    var currentAngle=(-0.5*Math.PI)+(i*perAngle)+(restAngle/2);
                    var currentLeft = Math.floor(Math.sin(currentAngle)*menuRadius);
                    var currentHeight = Math.floor(Math.sin(currentAngle-Math.PI/2)*menuRadius*scaleY);
                    
                    styleString+=
                    '.bottomRange.expand .bottomRangeMenu:nth-child('+(i+1)+'){'+
                        'transform:scale(1,1);'+
                        '-webkit-transform:scale(1,1);'+
                        '-webkit-transform: translate('+ currentLeft +'px,'+ currentHeight +'px);'+
                        'transform: translate('+ currentLeft +'px,'+ currentHeight +'px);'+
                      '}\n';
                }
                    styleString+=





                    styleString+='</style>';

                var menuString=
                '<link rel="stylesheet" type="text/css" href="../piece/css/cube-range-menu.css">'+
                '<footer '+menuId+' class="bottomRange">'+
                  '<div class="bottomRangeMenuBlock">'+
                    '<div class="menuBlock">'+
                        itemString+
                    '</div>'+
                    '<div class="bottomRangeBlock">'+
                      '<div class="bottomRangeButton">'+
                        menuName+'<br/>&nbsp;'+
                      '</div>'+
                    '</div>'+
                  '</div>'+
                  styleString+
                '</footer>';

                var finalEl = $(menuString);

                this.$(tag).replaceWith(finalEl);


                var rangeMenu = new RangeMenu({
                    el: finalEl
                });

               

                return rangeMenu;
            });


        }

    });
    return RangeMenu;
});