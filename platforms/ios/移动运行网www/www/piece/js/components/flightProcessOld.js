
define(['backbone', 'underscore', 'zepto', 'gmu'], function(Backbone, _, $, gmu) {


    var FlightProgress = Backbone.View.extend({

        events: {
            "click .roundBox_Over": "onBodyClick"
        },

        initialize: function(args) {
            var me = this;

        
        },
        onBodyClick: function(e){
            var target = e.currentTarget;

            var nodeName = e.toElement != null ? e.toElement.nodeName : e.target.nodeName;
            if (this.shouldPreventListEvent(nodeName)) {
                this.trigger("FlightProgress:click", this);
                //list, record(include event)
                this.trigger("click", this, {
                });
            }
        },
        shouldPreventListEvent: function(nodeName) {
            if (nodeName != 'TEXTAREA' && nodeName != 'INPUT' && nodeName != 'SELECT') return true;
            else return false;
        },
        el:null,
        setDegree: function(degree){
            var me = this;
            $(me.el).find('.colorBlock').removeClass('showBlock');
            $(me.el).find('.inBlock').animate({
                rotate: '0deg'
              },100,'linear');

            window.setTimeout(function(){
                $(me.el).find('.block').animate({
                    rotate: '0deg'
                  },50,'linear');
              },100);

            window.setTimeout(function(){
                    me._updateDegree(degree);
                  },180);
          
          

          
        },
        _updateDegree:function(degree){
            var me = this;
            var degreeValue = degree;

            var fullDegree = 360;
            var blockDegree = 90;

            var blockArray=['st','nd','rd','th'];

            var showBlockCount=Math.floor(degreeValue/blockDegree);
            var blockMainDegree = Math.floor(blockDegree*showBlockCount);
            var restDegree = degreeValue%blockDegree;

            var actions = [];
            for(var i=0;i<showBlockCount;i++){
                var action = {el:'.block',time:500,degree:90*(i+1),block:'.'+blockArray[i],
                next:function(block){
                  $(me.el).find(block).addClass('showBlock');
                  }
                }

                actions.push(action);

            }

            actions.push({el:'.inBlock',nextEl:'#planeContainer',time:500,degree:restDegree,nextDegree:degreeValue,block:'.inBlock',
            next:function(block){}
            })


            me.rotateEl(actions);
        },
        rotateEl:function(args){
            var me = this;
            if(args.length<=0){return;}
              


              var el = args[0].el;
              var time = args[0].time;
              var degree = args[0].degree;
              var next = args[0].next;
              var block = args[0].block;
              next(block);

              if(args[0].nextEl){
                var nextEl = args[0].nextEl;
                var nextDegree = args[0].nextDegree;
                $(me.el).find(nextEl).animate({
                    rotate: nextDegree+'deg',
                  }, time, 'linear',function(){
                  });
              }
              args.shift();


              if(!el)return;
               $(me.el).find(el).animate({
                    rotate: degree+'deg',
                  }, time, 'linear',function(){
                    me.rotateEl(args);
                  });
        }

    }, {
        compile: function(elContext) {
            var me = this;

            return _.map($(elContext).find("flightProgress"), function(tag) {
                var id= ($(tag).attr('id')&&$(tag).attr('id').length>0)? $(tag).attr('id'):'myFlightProgress';
                var initialValue = ($(tag).attr('value')&&$(tag).attr('value').length>0)? $(tag).attr('value') : '0';

                var roundBoxWidth = ($(tag).attr('width')&&$(tag).attr('width').length>0)? $(tag).attr('width') : 150;
                var roundBoxHeight = ($(tag).attr('height')&&$(tag).attr('height').length>0)? $(tag).attr('height') : roundBoxWidth;

                var bgColor = 'rgb(35,85,153)';
                var border_extend = 10;

                roundBoxWidth=roundBoxWidth/1;
                roundBoxHeight=roundBoxHeight/1;
                var boxScale=1;

                var styleString=
                    '<style>'+
                    '.roundBackColor{background-color: white;}'+
  
                    '.showBlock{ background-color: rgb(85,231,60);}'+

                  '.roundBox{'+
                    'position: absolute;'+
                    'margin: auto;'+
                    'top: 0px;'+
                    'left: 0px;'+
                    'width: '+roundBoxWidth+'px;'+
                    'height: '+roundBoxHeight+'px;'+
                    'border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    '-webkit-border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    '-moz-border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    'overflow: hidden;'+
                    'z-index: 99;'+
                    'border:'+Math.floor(roundBoxWidth/15)+'px solid rgb(0,130,222);'+
                    '-webkit-transform: scale('+boxScale+');'+
                    '-webkit-box-shadow: rgba(0, 0, 0, 0.4) 5px 5px 5px 0px;'+
                  '}'+

                  '.roundBox-extend{'+
                    'position: absolute;'+
                    'margin: auto;'+
                    'top: -'+border_extend+'px;'+
                    'left: -'+border_extend+'px;'+
                    'width: '+roundBoxWidth+'px;'+
                    'height: '+roundBoxHeight+'px;'+
                    'border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    '-webkit-border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    '-moz-border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    'overflow: hidden;'+
                    'z-index: 99;'+
                    'border:'+Math.floor(roundBoxWidth/15+border_extend)+'px solid '+ bgColor +';'+
                    'border-color:'+bgColor+';'+
                    '-webkit-transform: scale('+boxScale+');'+
                  '}'+

                  '.roundBox>table{'+
                    'border-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                    '-webkit-border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    '-moz-border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    'overflow:hidden;'+
                  '}'+

                  '.roundBox_Over{'+
                    'position: absolute;'+
                    'top: 0px;'+
                    'left: 0px;'+
                    'width: 80%;'+
                    'height: 80%;'+
                    'margin:10%;'+
                    'color: white;'+
                    'font-size: '+Math.floor(roundBoxWidth/5)+'px;'+
                    'border-radius: '+Math.floor(roundBoxWidth/0.4)+'px;'+
                    'overflow: hidden;'+
                    'z-index: 99;'+
                    'background-color: rgb(0,92,203);'+
                    'background-image: -moz-linear-gradient(top, rgb(0,146,230), rgb(0,92,203));'+
                    'background-image: -webkit-linear-gradient(top, rgb(0,146,230), rgb(0,92,203));'+
                    'text-align: center;'+
                  '}'+

                  '.roundBox .block{'+
                    'left: 50%;'+
                    'top:  0px;'+
                    'width: 50%;'+
                    'height: 50%;'+
                    'border-top-right-radius: '+Math.floor(roundBoxWidth/1.7)+'px;'+
                    'position: absolute;'+
                    'overflow: hidden;'+
                    'z-index: 96;'+
                    '-webkit-transform-origin:bottom left;'+
                  '}'+

                  '.roundBox .blockContainer{'+
                    'position: absolute;'+
                    'width: 100%;'+
                    'height: 100%;'+
                    'top:  0px;'+
                    'left: 0px;'+
                    'border: 0px solid red;'+
                    'border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    '-webkit-border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    '-moz-border-radius: '+Math.floor(roundBoxWidth/1.6)+'px;'+
                    'overflow: hidden;'+
                    'z-index: 97;'+
                  '}'+

                  '.roundBox .block .inBlock{'+
                    'left: 0px;'+
                    'top:  0%;'+
                    'width: 100%;'+
                    'height: 100%;'+
                    'position: absolute;'+
                    'z-index: 95;'+
                    'border-top-right-radius: '+Math.floor(roundBoxWidth/1.7)+'px;'+
                    '-webkit-transform:rotate(0deg);'+
                    '-webkit-transform-origin:bottom left;'+
                  '}'+

                  '.block .plane{'+
                  'position:relative;'+
                  'left:-20px;'+
                  'top:-2px;'+
                  'width:15px;'+
                  'height:15px;'+
                  'z-index:199;'+
                  '-webkit-transform:rotate(-129deg)'+
                  '}'+
                  // '.inBlock:before{'+
                  // 'width:10px;'+
                  // 'height:10px;'+
                  // 'position:relative;'+
                  // 'left:-10px;'+
                  // 'top:0px;'+
                  // 'background-color:red;'+
                  // 'content:"      1";'+
                  // 'background: url(icons/plane.png) no-repeat;'+
                  // '}'+

                  '.colorBlock.st{'+
                      'border-top-right-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-webkit-border-top-right-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-moz-border-top-right-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-o-border-top-right-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                    '}'+
                  '.colorBlock.nd{'+
                      'border-bottom-right-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-webkit-border-bottom-right-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-moz-border-bottom-right-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-o-border-bottom-right-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                    '}'+
                  '.colorBlock.rd{'+
                      'border-bottom-left-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-webkit-border-bottom-left-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-moz-border-bottom-left-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-o-border-bottom-left-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                    '}'+
                  '.colorBlock.th{'+
                      'border-top-left-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-webkit-border-top-left-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-moz-border-top-left-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                      '-o-border-top-left-radius: '+Math.floor(roundBoxWidth/1.8)+'px;'+
                    '}'+


                    '.center {'+
                        'display: -webkit-box;'+
                        '-webkit-box-orient: horizontal;'+
                        '-webkit-box-pack: center;'+
                        '-webkit-box-align: center;'+
                        'display: -moz-box;'+
                        '-moz-box-orient: horizontal;'+
                        '-moz-box-pack: center;'+
                        '-moz-box-align: center;'+
                        'display: -o-box;'+
                        '-o-box-orient: horizontal;'+
                        '-o-box-pack: center;'+
                        '-o-box-align: center;'+
                        'display: -ms-box;'+
                        '-ms-box-orient: horizontal;'+
                        '-ms-box-pack: center;'+
                        '-ms-box-align: center;'+
                        'display: box;'+
                        'box-orient: horizontal;'+
                        'box-pack: center;'+
                        'box-align: center;'+
                    '}'+

                    '.flightContainer{'+
                      'position: relative;'+
                      'text-align:center;'+
                      'width: '+(roundBoxWidth+Math.floor(roundBoxWidth/1.6)/3)+'px;'+
                      'height: '+(roundBoxWidth+Math.floor(roundBoxWidth/1.6)/3)+'px;'+
                      'margin:auto;'+
                      'top:0px;'+
                      'left:0px;'+
                    '}'+
                    '</style>';

                var menuString=
                  '<div class="flightContainer" id='+id+'>'+
                    '<div class="roundBox roundBackColor">'+
                        styleString+
                      '<table cellspacing="0" cellspanding="0" style="width:100%;height:100%;">'+
                        '<tr>'+
                            '<td class="colorBlock th">&nbsp;</td>'+
                            '<td class="colorBlock st">&nbsp;</td>'+
                        '</tr>'+
                        '<tr>'+
                          '<td class="colorBlock rd">&nbsp;</td>'+
                          '<td class="colorBlock nd">&nbsp;</td>'+
                        '</tr>'+
                      '</table>'+
                      '<div class="blockContainer">'+

                        '<div class="block showBlock">'+
                          '<div class="inBlock roundBackColor">'+
                          '<img class="plane" src="../com.csair.dynamic/images/plane.ing"/>'+
                          '</div>'+
                        '</div>'+

                        // '<div class="block" id="planeContainer" style="background-color:;overflow:auto;">'+
                        //   '<img class="plane" src="images/plane.png"/>'+
                        // '</div>'+
                      '</div>'+
                      
                    '</div>'+
                    '<div class="roundBox-extend">'+
                    '</div>'+
                    '<div class="roundBox">'+
                      '<div class="roundBox_Over center" style="opacity:1">已起飞</div>'+
                    '<div>'+
                  '</div>';

                var finalEl = $(menuString);

                this.$(tag).replaceWith(finalEl);


                var flightProgress = new FlightProgress({
                    el: finalEl
                });

               flightProgress.setDegree(initialValue);

                return flightProgress;
            });


        }

    });

    FlightProgress.prototype.text = function(text) {
        $(this.el).find('.roundBox_Over').text(text);
    };

    FlightProgress.prototype.updateProgress = function(degree) {
        this.setDegree(degree);
    };
    return FlightProgress;
});