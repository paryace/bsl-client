
define(['backbone', 'underscore', 'zepto', 'gmu'], function(Backbone, _, $, gmu) {


    var FlightProgress = Backbone.View.extend({

        events: {
            "click .canvas_Over": "onBodyClick"
        },

        initialize: function(args) {
            var me = this;
            me.canvas = args.canvas;
            me.canvasScale = args.canvasScale;

        
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
        canvas:null,
        canvasText:'',
        canvasScale:1,
        setDegree: function(process){
            var canvas = this.canvas;//DOM
            if (canvas == null) return false;
            var context = canvas.getContext('2d');
            var canvasWidth = $(canvas).parent().width();
            var canvasHeight = $(canvas).parent().height();
            $(canvas).attr({
              width:canvasWidth*this.canvasScale,
              height:canvasHeight*this.canvasScale
            });

            
            context.clearRect(0, 0, canvasWidth, canvasHeight);

            this.DrawToAngle(context,canvasWidth,canvasHeight,process,1000);

          
        },

        currentDegree:0,

        DrawToAngle:function(context,canvasWidth,canvasHeight,percent,time){
            var img = $("<img/>").attr('src','data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAlCAYAAADBa/A+AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QzA0QUZDOTMxOUJEMTFFMzg4QjNEMzVFM0YxQjVCNDgiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QzA0QUZDOTQxOUJEMTFFMzg4QjNEMzVFM0YxQjVCNDgiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpCRkFCODVGNjE5QkQxMUUzODhCM0QzNUUzRjFCNUI0OCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpCRkFCODVGNzE5QkQxMUUzODhCM0QzNUUzRjFCNUI0OCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pq3x2LwAAANmSURBVHjaYvz//z/DYAUspCjmKrkwDUhlQrkXgHj6tx6DWUToI9lhQHMZmEhwWGiQvkAmSBMInyhSN2BlZpwJFBejVcgxkaB2287rnxi+/voH5uhJcTKUOYuDmNUD7jhgaH0FOmw1yIEwAHIc0JF5wNBLG+iQA4HV6y59gHOA0cowK0KOgVbRS6rjUKKW1tHLRGIOwohaWkYvExl6UKKWltFLjuMwopZW0csE9GkyEJ8B4v9QPI2cqKVF9IJCLvNogZoxrHBNMBfOBBo+gdSoxRK94tRw3Ox5J9/CBSYEyTCYy3PnAw2vwaNv645rmFGLFr1V1HDc0pXn3jN8+QmxiA3o+2XxCgySfKzNQAfG4Ijab99+Y49aakYvI6hVAjRkxuRg2fRkS2G4xIkHXxk8pt9h+PX3fwUuzcC6tmNJrAJWuUvPvjPYTrzF8BuPfjTwFYi3APEDWMUPc5yxoQzXGWDaQ1G9+cpHhlMPv+I0jZONiaHKVQKn/Krz7xkuAx1JlMuASWQ7MCYevvvVD+QWgRzHAHIcCHMWnz999tHX/wMJvgODOWju3f9At+SA3IRczs2Zf+rtgDYuOViYGFq8pRhgbUZkx23ccuXTgLd+NcU5QJQWuuN8vbT4Btxx11/+AFHX0B2XlmwhPKAO+/HnH0PN1mcg5nR4HwKaW02MZLlQFO++8Ynh0vMfuJvurIwMmTaiOOVBuf3W659EOezZx98M2659hOXWKcgdnNQkc9RQOwksQkLn3weVc524DAzUEyjH5ThQORe7+AFe/WjgKcg/sHIO7DhgqPHwsDOlhxsJwlW9+PSbIWoh2OA4YHmzGEeHZ1WwvgBWW4AlAkPaikcg/emg3hk5vS9YmosGOQzoQLAA0ECGqEUPGJ5/+l2Hx2FcXKxMoe6a2DNQ976XoJCbREy3kZDjUhLNEFFauO4JqOqaCDS4GY8+L5DDuNmYsEZn156XIGY7NTrV020m3gIVeiZQMVBHuYCAvjBsUYoWnS8odhzQkHlAeh4JnWucUUqt6KSkme7toYUZpaDo7KRSdFLiuNAgPQGs0fmbStFJluNwRSm1o5PckMOIUlpEJ7mOQ4lSWkUnyY7DFqW0ik5yQg4lSmkZnSSPbAJDZzUw9KZzXbyAPrL5glaOYxzMY8IAAQYAAghPXCzdPFkAAAAASUVORK5CYII=');
            var planeWidth = 80;
            var planeHeigth = 76;
            var canvasScale = this.canvasScale;
            var valueScale = 1000;
            var resizeScale = Math.floor(valueScale*1/canvasScale)/valueScale;


            canvasWidth = canvasWidth*canvasScale;
            canvasHeight = canvasHeight*canvasScale;


            var degreeValue = percent*360/100;
            var frameTime = 20;
            var addingDegree = degreeValue/(time/frameTime);
            var addingRadius = Math.PI*2*addingDegree/360;
            var finalRadius = Math.PI*2*degreeValue/360;
            var centerPointX  = (canvasWidth/2);//*((3-canvasScale)/2);
            var centerPointY  = (canvasHeight/2);//*((3-canvasScale)/2);

            var zeroRadius = Math.PI/-2;
            var fullRadius = Math.PI*2;

            var fullShadow = 5*centerPointX/100;
            var zeroShadow = 0*canvasScale;
            var firstRadius = centerPointX-fullShadow*2;
            var secondBorder = fullShadow*2;
            var secondRadius = firstRadius-secondBorder;
            var thirdBorder = fullShadow*3;
            var thirdRadius = secondRadius-thirdBorder;

            var centerFontSize = (Math.floor(thirdRadius)/2);



            var that  = this;
            var innerInterval=setInterval(function(){
                context.clearRect(0, 0, canvasWidth, canvasHeight);



                context.fillStyle = 'rgb(0, 130, 222)';
                context.shadowColor = "#000000";
                shadowWidth = fullShadow;
                context.shadowOffsetX = shadowWidth;
                context.shadowOffsetY= shadowWidth;
                context.shadowBlur = shadowWidth;
                that.DrawSector(context,centerPointX, centerPointY, firstRadius, zeroRadius, fullRadius,true, false);


                shadowWidth = zeroShadow;
                context.shadowOffsetX = shadowWidth;
                context.shadowOffsetY= shadowWidth;
                context.shadowBlur = shadowWidth;
                context.fillStyle = 'rgb(255,255,255)';
                that.DrawSector(context,centerPointX, centerPointY, secondRadius, zeroRadius, fullRadius,true, false);
                context.fillStyle = 'rgb(85, 231, 60)';
                that.DrawSector(context,centerPointX, centerPointY, secondRadius, zeroRadius, that.currentDegree,true, false);
                


                context.fillStyle = 'rgb(0, 130, 222)';
                shadowWidth = zeroShadow;
                context.shadowOffsetX = shadowWidth;
                context.shadowOffsetY= shadowWidth;
                context.shadowBlur = shadowWidth;
                that.DrawSector(context,centerPointX, centerPointY, thirdRadius, zeroRadius, fullRadius,true, false);


                context.fillStyle = 'rgb(255, 255, 255)';
                context.font = centerFontSize+"px 'Helvetica Neue', sans-serif";
                context.textAlign = "center";
                context.textBaseline = "middle";
                context.fillText(that.canvasText,centerPointX,centerPointY,canvasWidth);



                var returnPosition = (3-canvasScale)/2;
                if(that.currentDegree>finalRadius){
                    clearInterval(innerInterval);
                    // alert((10-centerPointY))
                    // alert(returnPosition)
                    // alert((10-centerPointY)*(returnPosition))

                    context.save();
                    context.translate(centerPointX-5,centerPointY);
                    context.rotate(that.currentDegree);
                    context.scale(canvasScale, canvasScale);
                    context.drawImage(img[0],-10,(10-centerPointY/canvasScale),15,15);
                    context.restore();
                }else{
                    context.save();
                    context.translate(centerPointX-5,centerPointY);
                    context.scale(canvasScale, canvasScale);
                    context.rotate(that.currentDegree-addingRadius);
                    context.drawImage(img[0],-10,(10-centerPointY/canvasScale),15,15);
                    context.restore();
                }
                that.currentDegree+=addingRadius;



            },frameTime);
        },

        DrawSector: function(ctx,pointX,pointY,radius,start_angle,angle,fill,anticlockwise){
                var centerPoint = {x:pointX,y:pointY};
                start_angle = start_angle || 0;
                    ctx.beginPath();
                //画出弧线
                    ctx.arc(centerPoint.x,centerPoint.y,radius,start_angle,angle+Math.PI/-2,anticlockwise);
                //画出结束半径
                    ctx.lineTo(centerPoint.x,centerPoint.y);
               //如果需要填充就填充，不需要就算了
                    if (fill) {
                        ctx.fill();
                    }else{
                        ctx.closePath();
                        ctx.stroke();
                    }
            }

    }, {
        compile: function(elContext) {
            var me = this;

            return _.map($(elContext).find("flightProgress"), function(tag) {
                var id= ($(tag).attr('id')&&$(tag).attr('id').length>0)? $(tag).attr('id'):'myFlightProgress';
                var initialValue = ($(tag).attr('value')&&$(tag).attr('value').length>0)? $(tag).attr('value') : '0';

                var roundBoxWidth = ($(tag).attr('width')&&$(tag).attr('width').length>0)? $(tag).attr('width') : 150;
                var roundBoxHeight = ($(tag).attr('height')&&$(tag).attr('height').length>0)? $(tag).attr('height') : roundBoxWidth;

                var canvasScale = ($(tag).attr('canvasScale')&&$(tag).attr('canvasScale').length>0&&parseInt($(tag).attr('canvasScale'))>0)? parseInt($(tag).attr('canvasScale')) : 2;

                var valueScale = 1000;
                var resizeScale = Math.floor(valueScale*1/canvasScale)/valueScale;


                roundBoxWidth=roundBoxWidth/1;
                roundBoxHeight=roundBoxHeight/1;

                var canContainer = $("<div/>").addClass("canvas_Over").attr("id",id).css({
                  width:roundBoxWidth,
                  height:roundBoxHeight,
                  margin:'auto',
                  position:'relative'
                });
                var canvas = $("<canvas/>").css({
                  width:roundBoxWidth*canvasScale,
                  height:roundBoxHeight*canvasScale,
                  left:(roundBoxWidth*(1-canvasScale)/2),
                  top:(roundBoxHeight*(1-canvasScale)/2),
                  position:'absolute',
                  'z-index':3,
                  '-webkit-transform':'scale('+resizeScale+','+resizeScale+')'
                });


                canContainer.append(canvas);

                this.$(tag).replaceWith(canContainer);

                var flightProgress = new FlightProgress({
                    el: canContainer,
                    canvas:canvas[0],
                    canvasScale:canvasScale
                });



               // flightProgress.setDegree(initialValue);

                return flightProgress;
            });


        }

    });

    FlightProgress.prototype.text = function(text) {
        this.canvasText = text;
    };

    FlightProgress.prototype.updateProgress = function(degree) {
        this.setDegree(degree);
    };


    return FlightProgress;
});