/*
 * JS中初始化该控件。
 * var loader = new Loader({
 *       autoshow:false,    //是否初始化时就弹出加载控件
 *       target:'#test'     //页面目标组件表识
 *  });
 * loader.show();       //显示加载窗
 * loader.hide();       //隐藏加载窗
 * loader.hideAll();    //隐藏所有加载窗
 * 
 * loading组件，最终转换出html5
 * <div class="cube-loader">
 *      <div class="cube-loader-icon">
 *      </div>
 * </div>
 */
define(['zepto'], function($){

    var me;
    var canceled;
    var keys = [37, 38, 39, 40];

    function preventDefault(e) {
      e = e || window.event;
      if (e.preventDefault)
          e.preventDefault();
      e.returnValue = false;  
    }
    
    function keydown(e) {
        for (var i = keys.length; i--;) {
            if (e.keyCode === keys[i]) {
                preventDefault(e);
                return;
            }
        }
    }

    function scrolling(e) {
        preventDefault(e);
    }

    function disableScrolling(){
        if(window.addEventListener){
            window.addEventListener('DOMMouseScroll', scrolling, false);
            window.addEventListener('touchmove',scrolling,false);
            window.onmousewheel = document.onmousewheel = scrolling;
            document.onkeydown = keydown;
        }
    }

    function enableScrolling(){
        if (window.removeEventListener) {
            window.removeEventListener('DOMMouseScroll', scrolling, false);
            window.removeEventListener('touchmove',scrolling,false);
        }
        window.onmousewheel = document.onmousewheel = document.onkeydown = null;
    }
    
    //判断是否已替换，来判断是否已经构造完成
    var Loader = function(config){
        this.config = {autoshow : true, target: 'body', text: '载入中...',cancelable:true};
        canceled = false;
        if(config) {
            this.config = $.extend(this.config, config);
        }
        if(this.config.autoshow) {
            this.show();
        }
    };

    //change事件需要执行用户自定义事件，还要广播事件。
    Loader.prototype.show = function() {
        me = this;
        disableScrolling();
        var targetOjb = $(this.config.target);
        this.find = (this.find)? this.find:this.findBackUp;
        var cube_loader =  this.find();
        if(cube_loader) return;

        cube_loader = $("<div/>").addClass("cube-loader");
        
        var cube_loader_block = $("<div/>").addClass("cube-loader-block");
        var cube_loader_icon = $("<img/>").addClass("cube-loader-icon").attr('src','data:img/jpg;base64,iVBORw0KGgoAAAANSUhEUgAAAEYAAABGBAMAAACDAP+3AAAAHlBMVEX///+3t7e6urq4uLi4uLi5ubm5ubm5ubm5ubm5ubm/fxe2AAAACXRSTlMAIEaMjaPH8PN2+20BAAAA80lEQVR4XsWWLQ4CMRCFgRCwGDzHAIfCcwMEB8BxABQaw9yWAE1HfOS9bjahI799See187OTjjE7XM8bLZluI+K2kpp1vOMoNbuP5iGzuX80T5XRPL6xF3YWRXOqhHaWRXOphHZSUwjt5FmV0E7NmQb5iQZ5RJISTDUJNbwEnsXLZM4k9E7COwThW5DwTUlYGyB/6ClypgcOm7Aveqpw0VPJRU8lRxn8KhiUEwqvTePPaszZe/d32PYW/k1RA11KkcT3ju9B38t+JvjZMmRG+VnnZ6afvX6GN+8Cv1P8bvI7btiupMFRuzsNjv2XgB1R/P3iBSZwz1CJGJLVAAAAAElFTkSuQmCC');
        var cube_cancel_icon = $("<img/>").addClass("cube-loader-cancel");
        cube_cancel_icon.click(function(){
            enableScrolling();
            if(me.config.cancelable!=false){
                cube_loader.remove();
                canceled = true;
            }
        });
        cube_cancel_icon[0].src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC4AAAAuCAYAAABXuSs3AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyBpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYwIDYxLjEzNDc3NywgMjAxMC8wMi8xMi0xNzozMjowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNSBXaW5kb3dzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjc2NUIyNTY4N0NGODExRTI4NTM0QTk5OUJEQjdBQzlGIiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjc2NUIyNTY5N0NGODExRTI4NTM0QTk5OUJEQjdBQzlGIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6NzY1QjI1NjY3Q0Y4MTFFMjg1MzRBOTk5QkRCN0FDOUYiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NzY1QjI1Njc3Q0Y4MTFFMjg1MzRBOTk5QkRCN0FDOUYiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4Lar7mAAAG1klEQVR42syaeWxUVRTG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";

        // var p = $("<p/>").append(this.config.text);
        cube_loader_block.append(cube_loader_icon);
        // cube_loader_block.append(p);
        cube_loader.append(cube_loader_block);
        cube_loader.append(cube_cancel_icon);

        var children = $(this.config.target).children();
        if(children && children.length>0) {
            children.first().before(cube_loader);
        } else {
            $(targetOjb).append(cube_loader);
        }
    };

    //
    Loader.prototype.hide = function() {
        enableScrolling();
        var cube_loader = this.find();
        if(cube_loader) $(cube_loader).remove();
    };

    Loader.prototype.hideAll = function() {
        enableScrolling();
        var cube_loader = $(".cube-loader");
        if(cube_loader && cube_loader.length>0) {
            $(cube_loader).each(function(){
                $(this).remove();
            });
        }
    };

    Loader.prototype.find = function() {
        var targetOjb = $(this.config.target);
        var result;
        var children = targetOjb.children();
        $(children).each(function(){
            if($(this).hasClass("cube-loader")) {
                result = this;
            }
        });
        return result;
    }

    Loader.prototype.findBackUp = function() {
        var targetOjb = $(this.config.target);
        var result;
        var children = targetOjb.children();
        $(children).each(function(){
            if($(this).hasClass("cube-flight-loader")) {
                result = this;
            }
        });
        return result;
    };

    Loader.prototype.isCanceled = function(){
        return canceled;
    }
    return Loader;
});