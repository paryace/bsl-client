/*!Extend touch.js*/
(function(i){var g={},b,k,h,e=750,a;function c(m){return"tagName" in m?m:m.parentNode}function j(n,m,p,o){var r=Math.abs(n-m),q=Math.abs(p-o);return r>=q?(n-m>0?"Left":"Right"):(p-o>0?"Up":"Down")}function l(){a=null;if(g.last){g.el.trigger("longTap");g={}}}function d(){if(a){clearTimeout(a)}a=null}function f(){if(b){clearTimeout(b)}if(k){clearTimeout(k)}if(h){clearTimeout(h)}if(a){clearTimeout(a)}b=k=h=a=null;g={}}i(document).ready(function(){var m,n;i(document.body).bind("touchstart",function(o){m=Date.now();n=m-(g.last||m);g.el=i(c(o.touches[0].target));b&&clearTimeout(b);g.x1=o.touches[0].pageX;g.y1=o.touches[0].pageY;if(n>0&&n<=250){g.isDoubleTap=true}g.last=m;a=setTimeout(l,e)}).bind("touchmove",function(o){d();g.x2=o.touches[0].pageX;g.y2=o.touches[0].pageY;if(Math.abs(g.x1-g.x2)>10){o.preventDefault()}}).bind("touchend",function(o){d();if((g.x2&&Math.abs(g.x1-g.x2)>30)||(g.y2&&Math.abs(g.y1-g.y2)>30)){h=setTimeout(function(){g.el.trigger("swipe");g.el.trigger("swipe"+(j(g.x1,g.x2,g.y1,g.y2)));g={}},0)}else{if("last" in g){k=setTimeout(function(){var p=i.Event("tap");p.cancelTouch=f;g.el.trigger(p);if(g.isDoubleTap){g.el.trigger("doubleTap");g={}}else{b=setTimeout(function(){b=null;g.el.trigger("singleTap");g={}},250)}},0)}}}).bind("touchcancel",f);i(window).bind("scroll",f)});["swipe","swipeLeft","swipeRight","swipeUp","swipeDown","doubleTap","tap","singleTap","longTap"].forEach(function(n){i.fn[n]=function(m){return this.bind(n,m)}})})(Zepto);
/*!Extend zepto.extend.js*/
(function(a){a.extend(a,{contains:function(b,c){return b.compareDocumentPosition?!!(b.compareDocumentPosition(c)&16):b!==c&&b.contains(c)}})})(Zepto);(function(a,c){a.extend(a,{toString:function(d){return Object.prototype.toString.call(d)},slice:function(e,d){return Array.prototype.slice.call(e,d||0)},later:function(f,d,h,e,g){return window["set"+(h?"Interval":"Timeout")](function(){f.apply(e,g)},d||0)},parseTpl:function(g,f){var d="var __p=[],print=function(){__p.push.apply(__p,arguments);};with(obj||{}){__p.push('"+g.replace(/\\/g,"\\\\").replace(/'/g,"\\'").replace(/<%=([\s\S]+?)%>/g,function(h,i){return"',"+i.replace(/\\'/g,"'")+",'"}).replace(/<%([\s\S]+?)%>/g,function(h,i){return"');"+i.replace(/\\'/g,"'").replace(/[\r\n\t]/g," ")+"__p.push('"}).replace(/\r/g,"\\r").replace(/\n/g,"\\n").replace(/\t/g,"\\t")+"');}return __p.join('');";var e=new Function("obj",d);return f?e(f):e},throttle:function(d,e,i){var g=0,f;if(typeof e!=="function"){i=e;e=d;d=250}function h(){var m=this,n=Date.now()-g,l=arguments;function k(){g=Date.now();e.apply(m,l)}function j(){f=c}if(i&&!f){k()}f&&clearTimeout(f);if(i===c&&n>d){k()}else{f=setTimeout(i?j:k,i===c?d-n:d)}}h._zid=e._zid=e._zid||a.proxy(e)._zid;return h},debounce:function(d,f,e){return f===c?a.throttle(250,d,false):a.throttle(d,f,e===c?false:e!==false)}});a.each("String Boolean RegExp Number Date Object Null Undefined".split(" "),function(e,d){var f;if("is"+d in a){return}switch(d){case"Null":f=function(g){return g===null};break;case"Undefined":f=function(g){return g===c};break;default:f=function(g){return new RegExp(d+"]","i").test(b(g))}}a["is"+d]=f});var b=a.toString})(Zepto);(function(d,g){var c=navigator.userAgent,a=navigator.appVersion,b=d.browser;d.extend(b,{qq:/qq/i.test(c),uc:/UC/i.test(c)||/UC/i.test(a)});b.uc=b.uc||!b.qq&&!b.chrome&&!b.firefox&&!/safari/i.test(c);try{b.version=b.uc?a.match(/UC(?:Browser)?\/([\d.]+)/)[1]:b.qq?c.match(/MQQBrowser\/([\d.]+)/)[1]:b.version}catch(f){}d.support=d.extend(d.support||{},{orientation:!(b.uc||(parseFloat(d.os.version)<5&&(b.qq||b.chrome)))&&!(d.os.android&&parseFloat(d.os.version)>3)&&"orientation" in window&&"onorientationchange" in window,touch:"ontouchend" in document,cssTransitions:"WebKitTransitionEvent" in window,has3d:"WebKitCSSMatrix" in window&&"m11" in new WebKitCSSMatrix()})})(Zepto);(function(b){b.matchMedia=(function(){var g=0,e="gmu-media-detect",d=b.fx.transitionEnd,h=b.fx.cssPrefix,f=b("<style></style>").append("."+e+"{"+h+"transition: width 0.001ms; width: 0; position: absolute; top: -10000px;}\n").appendTo("head");return function(k){var m=e+g++,l=b('<div class="'+e+'" id="'+m+'"></div>').appendTo("body"),j=[],i;f.append("@media "+k+" { #"+m+" { width: 1px; } }\n");if("matchMedia" in window){return window.matchMedia(k)}l.on(d,function(){i.matches=l.width()===1;b.each(j,function(n,o){b.isFunction(o)&&o.call(i,i)})});i={matches:l.width()===1,media:k,addListener:function(n){j.push(n);return this},removeListener:function(o){var n=j.indexOf(o);~n&&j.splice(n,1);return this}};return i}}());b(function(){var d=function(e){b(window).trigger("ortchange")};b.mediaQuery={ortchange:"screen and (width: "+window.innerWidth+"px)"};b.matchMedia(b.mediaQuery.ortchange).addListener(d)});function a(){b(window).on("scroll",b.debounce(80,function(){b(document).trigger("scrollStop")},false))}function c(){b(window).off("scroll");a()}a();b(window).on("pageshow",function(d){if(d.persisted){b(document).off("touchstart",c).one("touchstart",c)}})})(Zepto);
/*!Extend zepto.highlight.js*/
(function(e){var d,a=false,f,c,b=function(){clearTimeout(f);if(d&&(c=d.attr("highlight-cls"))){d.removeClass(c).attr("highlight-cls","");d=null}};e.extend(e.fn,{highlight:function(g){a=a||!!e(document).on("touchend.highlight touchmove.highlight touchcancel.highlight",b);b();return this.each(function(){var h=e(this);h.css("-webkit-tap-highlight-color","rgba(255,255,255,0)").off("touchstart.highlight");g&&h.on("touchstart.highlight",function(){f=e.later(function(){d=h.attr("highlight-cls",g).addClass(g)},100)})})}})})(Zepto);


/*!
 * iScroll v4.2.2 ~ Copyright (c) 2012 Matteo Spinelli, http://cubiq.org
 * Released under MIT license, http://cubiq.org/license
 */
(function(window, doc){
    var m = Math,_bindArr = [],
        dummyStyle = doc.createElement('div').style,
        vendor = (function () {
            var vendors = 'webkitT,MozT,msT,OT,t'.split(','),
                t,
                i = 0,
                l = vendors.length;

            for ( ; i < l; i++ ) {
                t = vendors[i] + 'ransform';
                if ( t in dummyStyle ) {
                    return vendors[i].substr(0, vendors[i].length - 1);
                }
            }

            return false;
        })(),
        cssVendor = vendor ? '-' + vendor.toLowerCase() + '-' : '',


    // Style properties
        transform = prefixStyle('transform'),
        transitionProperty = prefixStyle('transitionProperty'),
        transitionDuration = prefixStyle('transitionDuration'),
        transformOrigin = prefixStyle('transformOrigin'),
        transitionTimingFunction = prefixStyle('transitionTimingFunction'),
        transitionDelay = prefixStyle('transitionDelay'),

    // Browser capabilities
        isAndroid = (/android/gi).test(navigator.appVersion),
        isTouchPad = (/hp-tablet/gi).test(navigator.appVersion),

        has3d = prefixStyle('perspective') in dummyStyle,
        hasTouch = 'ontouchstart' in window && !isTouchPad,
        hasTransform = !!vendor,
        hasTransitionEnd = prefixStyle('transition') in dummyStyle,

        RESIZE_EV = 'onorientationchange' in window ? 'orientationchange' : 'resize',
        START_EV = hasTouch ? 'touchstart' : 'mousedown',
        MOVE_EV = hasTouch ? 'touchmove' : 'mousemove',
        END_EV = hasTouch ? 'touchend' : 'mouseup',
        CANCEL_EV = hasTouch ? 'touchcancel' : 'mouseup',
        TRNEND_EV = (function () {
            if ( vendor === false ) return false;

            var transitionEnd = {
                ''			: 'transitionend',
                'webkit'	: 'webkitTransitionEnd',
                'Moz'		: 'transitionend',
                'O'			: 'otransitionend',
                'ms'		: 'MSTransitionEnd'
            };

            return transitionEnd[vendor];
        })(),

        nextFrame = (function() {
            return window.requestAnimationFrame ||
                window.webkitRequestAnimationFrame ||
                window.mozRequestAnimationFrame ||
                window.oRequestAnimationFrame ||
                window.msRequestAnimationFrame ||
                function(callback) { return setTimeout(callback, 1); };
        })(),
        cancelFrame = (function () {
            return window.cancelRequestAnimationFrame ||
                window.webkitCancelAnimationFrame ||
                window.webkitCancelRequestAnimationFrame ||
                window.mozCancelRequestAnimationFrame ||
                window.oCancelRequestAnimationFrame ||
                window.msCancelRequestAnimationFrame ||
                clearTimeout;
        })(),

    // Helpers
        translateZ = has3d ? ' translateZ(0)' : '',

    // Constructor
        iScroll = function (el, options) {
            var that = this,
                i;

            that.wrapper = typeof el == 'object' ? el : doc.getElementById(el);
            that.wrapper.style.overflow = 'hidden';
            that.scroller = that.wrapper.children[0];

            that.translateZ = translateZ;
            // Default options
            that.options = {
                hScroll: true,
                vScroll: true,
                x: 0,
                y: 0,
                bounce: true,
                bounceLock: false,
                momentum: true,
                lockDirection: true,
                useTransform: true,
                useTransition: false,
                topOffset: 0,
                checkDOMChanges: false,		// Experimental
                handleClick: true,


                // Events
                onRefresh: null,
                onBeforeScrollStart: function (e) { e.preventDefault(); },
                onScrollStart: null,
                onBeforeScrollMove: null,
                onScrollMove: null,
                onBeforeScrollEnd: null,
                onScrollEnd: null,
                onTouchEnd: null,
                onDestroy: null

            };

            // User defined options
            for (i in options) that.options[i] = options[i];

            // Set starting position
            that.x = that.options.x;
            that.y = that.options.y;

            // Normalize options
            that.options.useTransform = hasTransform && that.options.useTransform;

            that.options.useTransition = hasTransitionEnd && that.options.useTransition;



            // Set some default styles
            that.scroller.style[transitionProperty] = that.options.useTransform ? cssVendor + 'transform' : 'top left';
            that.scroller.style[transitionDuration] = '0';
            that.scroller.style[transformOrigin] = '0 0';
            if (that.options.useTransition) that.scroller.style[transitionTimingFunction] = 'cubic-bezier(0.33,0.66,0.66,1)';

            if (that.options.useTransform) that.scroller.style[transform] = 'translate(' + that.x + 'px,' + that.y + 'px)' + translateZ;
            else that.scroller.style.cssText += ';position:absolute;top:' + that.y + 'px;left:' + that.x + 'px';



            that.refresh();

            that._bind(RESIZE_EV, window);
            that._bind(START_EV);


            if (that.options.checkDOMChanges) that.checkDOMTime = setInterval(function () {
                that._checkDOMChanges();
            }, 500);
        };

// Prototype
    iScroll.prototype = {
        enabled: true,
        x: 0,
        y: 0,
        steps: [],
        scale: 1,
        currPageX: 0, currPageY: 0,
        pagesX: [], pagesY: [],
        aniTime: null,
        isStopScrollAction:false,

        handleEvent: function (e) {
            var that = this;
            switch(e.type) {
                case START_EV:
                    if (!hasTouch && e.button !== 0) return;
                    that._start(e);
                    break;
                case MOVE_EV: that._move(e); break;
                case END_EV:
                case CANCEL_EV: that._end(e); break;
                case RESIZE_EV: that._resize(); break;
                case TRNEND_EV: that._transitionEnd(e); break;
            }
        },

        _checkDOMChanges: function () {
            if (this.moved ||  this.animating ||
                (this.scrollerW == this.scroller.offsetWidth * this.scale && this.scrollerH == this.scroller.offsetHeight * this.scale)) return;

            this.refresh();
        },

        _resize: function () {
            var that = this;
            setTimeout(function () { that.refresh(); }, isAndroid ? 200 : 0);
        },

        _pos: function (x, y) {
            x = this.hScroll ? x : 0;
            y = this.vScroll ? y : 0;

            if (this.options.useTransform) {
                this.scroller.style[transform] = 'translate(' + x + 'px,' + y + 'px) scale(' + this.scale + ')' + translateZ;
            } else {
                x = m.round(x);
                y = m.round(y);
                this.scroller.style.left = x + 'px';
                this.scroller.style.top = y + 'px';
            }

            this.x = x;
            this.y = y;

        },



        _start: function (e) {
            var that = this,
                point = hasTouch ? e.touches[0] : e,
                matrix, x, y,
                c1, c2;

            if (!that.enabled) return;

            if (that.options.onBeforeScrollStart) that.options.onBeforeScrollStart.call(that, e);

            if (that.options.useTransition ) that._transitionTime(0);

            that.moved = false;
            that.animating = false;

            that.distX = 0;
            that.distY = 0;
            that.absDistX = 0;
            that.absDistY = 0;
            that.dirX = 0;
            that.dirY = 0;
            that.isStopScrollAction = false;

            if (that.options.momentum) {
                if (that.options.useTransform) {
                    // Very lame general purpose alternative to CSSMatrix
                    matrix = getComputedStyle(that.scroller, null)[transform].replace(/[^0-9\-.,]/g, '').split(',');
                    x = +matrix[4];
                    y = +matrix[5];
                } else {
                    x = +getComputedStyle(that.scroller, null).left.replace(/[^0-9-]/g, '');
                    y = +getComputedStyle(that.scroller, null).top.replace(/[^0-9-]/g, '');
                }

                if (x != that.x || y != that.y) {
                    that.isStopScrollAction = true;
                    if (that.options.useTransition) that._unbind(TRNEND_EV);
                    else cancelFrame(that.aniTime);
                    that.steps = [];
                    that._pos(x, y);
                    if (that.options.onScrollEnd) that.options.onScrollEnd.call(that);
                }
            }



            that.startX = that.x;
            that.startY = that.y;
            that.pointX = point.pageX;
            that.pointY = point.pageY;

            that.startTime = e.timeStamp || Date.now();

            if (that.options.onScrollStart) that.options.onScrollStart.call(that, e);

            that._bind(MOVE_EV, window);
            that._bind(END_EV, window);
            that._bind(CANCEL_EV, window);
        },

        _move: function (e) {
            var that = this,
                point = hasTouch ? e.touches[0] : e,
                deltaX = point.pageX - that.pointX,
                deltaY = point.pageY - that.pointY,
                newX = that.x + deltaX,
                newY = that.y + deltaY,

                timestamp = e.timeStamp || Date.now();

            if (that.options.onBeforeScrollMove) that.options.onBeforeScrollMove.call(that, e);

            that.pointX = point.pageX;
            that.pointY = point.pageY;

            // Slow down if outside of the boundaries
            if (newX > 0 || newX < that.maxScrollX) {
                newX = that.options.bounce ? that.x + (deltaX / 2) : newX >= 0 || that.maxScrollX >= 0 ? 0 : that.maxScrollX;
            }
            if (newY > that.minScrollY || newY < that.maxScrollY) {
                newY = that.options.bounce ? that.y + (deltaY / 2) : newY >= that.minScrollY || that.maxScrollY >= 0 ? that.minScrollY : that.maxScrollY;
            }

            that.distX += deltaX;
            that.distY += deltaY;
            that.absDistX = m.abs(that.distX);
            that.absDistY = m.abs(that.distY);

            if (that.absDistX < 6 && that.absDistY < 6) {
                return;
            }

            // Lock direction
            if (that.options.lockDirection) {
                if (that.absDistX > that.absDistY + 5) {
                    newY = that.y;
                    deltaY = 0;
                } else if (that.absDistY > that.absDistX + 5) {
                    newX = that.x;
                    deltaX = 0;
                }
            }

            that.moved = true;

            // internal for header scroll

            that._beforePos ? that._beforePos(newY, deltaY) && that._pos(newX, newY) : that._pos(newX, newY);

            that.dirX = deltaX > 0 ? -1 : deltaX < 0 ? 1 : 0;
            that.dirY = deltaY > 0 ? -1 : deltaY < 0 ? 1 : 0;

            if (timestamp - that.startTime > 300) {
                that.startTime = timestamp;
                that.startX = that.x;
                that.startY = that.y;
            }

            if (that.options.onScrollMove) that.options.onScrollMove.call(that, e);
        },

        _end: function (e) {
            if (hasTouch && e.touches.length !== 0) return;

            var that = this,
                point = hasTouch ? e.changedTouches[0] : e,
                target, ev,
                momentumX = { dist:0, time:0 },
                momentumY = { dist:0, time:0 },
                duration = (e.timeStamp || Date.now()) - that.startTime,
                newPosX = that.x,
                newPosY = that.y,
                newDuration;


            that._unbind(MOVE_EV, window);
            that._unbind(END_EV, window);
            that._unbind(CANCEL_EV, window);

            if (that.options.onBeforeScrollEnd) that.options.onBeforeScrollEnd.call(that, e);


            if (!that.moved) {

                if (hasTouch && this.options.handleClick && !that.isStopScrollAction) {
                    that.doubleTapTimer = setTimeout(function () {
                        that.doubleTapTimer = null;

                        // Find the last touched element
                        target = point.target;
                        while (target.nodeType != 1) target = target.parentNode;

                        if (target.tagName != 'SELECT' && target.tagName != 'INPUT' && target.tagName != 'TEXTAREA') {
                            ev = doc.createEvent('MouseEvents');
                            ev.initMouseEvent('click', true, true, e.view, 1,
                                point.screenX, point.screenY, point.clientX, point.clientY,
                                e.ctrlKey, e.altKey, e.shiftKey, e.metaKey,
                                0, null);
                            ev._fake = true;
                            // target.dispatchEvent(ev);
                        }
                    },  0);
                }


                that._resetPos(400);

                if (that.options.onTouchEnd) that.options.onTouchEnd.call(that, e);
                return;
            }

            if (duration < 300 && that.options.momentum) {
                momentumX = newPosX ? that._momentum(newPosX - that.startX, duration, -that.x, that.scrollerW - that.wrapperW + that.x, that.options.bounce ? that.wrapperW : 0) : momentumX;
                momentumY = newPosY ? that._momentum(newPosY - that.startY, duration, -that.y, (that.maxScrollY < 0 ? that.scrollerH - that.wrapperH + that.y - that.minScrollY : 0), that.options.bounce ? that.wrapperH : 0) : momentumY;

                newPosX = that.x + momentumX.dist;
                newPosY = that.y + momentumY.dist;

                if ((that.x > 0 && newPosX > 0) || (that.x < that.maxScrollX && newPosX < that.maxScrollX)) momentumX = { dist:0, time:0 };
                if ((that.y > that.minScrollY && newPosY > that.minScrollY) || (that.y < that.maxScrollY && newPosY < that.maxScrollY)) momentumY = { dist:0, time:0 };
            }

            if (momentumX.dist || momentumY.dist) {
                newDuration = m.max(m.max(momentumX.time, momentumY.time), 10);



                that.scrollTo(m.round(newPosX), m.round(newPosY), newDuration);

                if (that.options.onTouchEnd) that.options.onTouchEnd.call(that, e);
                return;
            }



            that._resetPos(200);
            if (that.options.onTouchEnd) that.options.onTouchEnd.call(that, e);
        },

        _resetPos: function (time) {
            var that = this,
                resetX = that.x >= 0 ? 0 : that.x < that.maxScrollX ? that.maxScrollX : that.x,
                resetY = that.y >= that.minScrollY || that.maxScrollY > 0 ? that.minScrollY : that.y < that.maxScrollY ? that.maxScrollY : that.y;

            if (resetX == that.x && resetY == that.y) {
                if (that.moved) {
                    that.moved = false;
                    if (that.options.onScrollEnd) that.options.onScrollEnd.call(that);		// Execute custom code on scroll end
                    if (that._afterPos) that._afterPos();
                }

                return;
            }

            that.scrollTo(resetX, resetY, time || 0);
        },



        _transitionEnd: function (e) {
            var that = this;

            if (e.target != that.scroller) return;

            that._unbind(TRNEND_EV);

            that._startAni();
        },


        /**
         *
         * Utilities
         *
         */
        _startAni: function () {
            var that = this,
                startX = that.x, startY = that.y,
                startTime = Date.now(),
                step, easeOut,
                animate;

            if (that.animating) return;

            if (!that.steps.length) {
                that._resetPos(400);
                return;
            }

            step = that.steps.shift();

            if (step.x == startX && step.y == startY) step.time = 0;

            that.animating = true;
            that.moved = true;

            if (that.options.useTransition) {
                that._transitionTime(step.time);
                that._pos(step.x, step.y);
                that.animating = false;
                if (step.time) that._bind(TRNEND_EV);
                else that._resetPos(0);
                return;
            }

            animate = function () {
                var now = Date.now(),
                    newX, newY;

                if (now >= startTime + step.time) {
                    that._pos(step.x, step.y);
                    that.animating = false;
                    if (that.options.onAnimationEnd) that.options.onAnimationEnd.call(that);			// Execute custom code on animation end
                    that._startAni();
                    return;
                }

                now = (now - startTime) / step.time - 1;
                easeOut = m.sqrt(1 - now * now);
                newX = (step.x - startX) * easeOut + startX;
                newY = (step.y - startY) * easeOut + startY;
                that._pos(newX, newY);
                if (that.animating) that.aniTime = nextFrame(animate);
            };

            animate();
        },

        _transitionTime: function (time) {
            time += 'ms';
            this.scroller.style[transitionDuration] = time;

        },

        _momentum: function (dist, time, maxDistUpper, maxDistLower, size) {
            var deceleration = 0.0006,
                speed = m.abs(dist) * (this.options.speedScale||1) / time,
                newDist = (speed * speed) / (2 * deceleration),
                newTime = 0, outsideDist = 0;

            // Proportinally reduce speed if we are outside of the boundaries
            if (dist > 0 && newDist > maxDistUpper) {
                outsideDist = size / (6 / (newDist / speed * deceleration));
                maxDistUpper = maxDistUpper + outsideDist;
                speed = speed * maxDistUpper / newDist;
                newDist = maxDistUpper;
            } else if (dist < 0 && newDist > maxDistLower) {
                outsideDist = size / (6 / (newDist / speed * deceleration));
                maxDistLower = maxDistLower + outsideDist;
                speed = speed * maxDistLower / newDist;
                newDist = maxDistLower;
            }

            newDist = newDist * (dist < 0 ? -1 : 1);
            newTime = speed / deceleration;

            return { dist: newDist, time: m.round(newTime) };
        },

        _offset: function (el) {
            var left = -el.offsetLeft,
                top = -el.offsetTop;

            while (el = el.offsetParent) {
                left -= el.offsetLeft;
                top -= el.offsetTop;
            }

            if (el != this.wrapper) {
                left *= this.scale;
                top *= this.scale;
            }

            return { left: left, top: top };
        },



        _bind: function (type, el, bubble) {
            _bindArr.concat([el || this.scroller, type, this]);
            (el || this.scroller).addEventListener(type, this, !!bubble);
        },

        _unbind: function (type, el, bubble) {
            (el || this.scroller).removeEventListener(type, this, !!bubble);
        },


        /**
         *
         * Public methods
         *
         */
        destroy: function () {
            var that = this;

            that.scroller.style[transform] = '';



            // Remove the event listeners
            that._unbind(RESIZE_EV, window);
            that._unbind(START_EV);
            that._unbind(MOVE_EV, window);
            that._unbind(END_EV, window);
            that._unbind(CANCEL_EV, window);



            if (that.options.useTransition) that._unbind(TRNEND_EV);

            if (that.options.checkDOMChanges) clearInterval(that.checkDOMTime);

            if (that.options.onDestroy) that.options.onDestroy.call(that);

            //清除所有绑定的事件
            for (var i = 0, l = _bindArr.length; i < l;) {
                _bindArr[i].removeEventListener(_bindArr[i + 1], _bindArr[i + 2]);
                _bindArr[i] = null;
                i = i + 3
            }
            _bindArr = [];

            //干掉外边的容器内容
            var div = doc.createElement('div');
            div.appendChild(this.wrapper);
            div.innerHTML = '';
            that.wrapper = that.scroller = div = null;
        },

        refresh: function () {
            var that = this,
                offset;



            that.wrapperW = that.wrapper.clientWidth || 1;
            that.wrapperH = that.wrapper.clientHeight || 1;

            that.minScrollY = -that.options.topOffset || 0;
            that.scrollerW = m.round(that.scroller.offsetWidth * that.scale);
            that.scrollerH = m.round((that.scroller.offsetHeight + that.minScrollY) * that.scale);
            that.maxScrollX = that.wrapperW - that.scrollerW;
            that.maxScrollY = that.wrapperH - that.scrollerH + that.minScrollY;
            that.dirX = 0;
            that.dirY = 0;

            if (that.options.onRefresh) that.options.onRefresh.call(that);

            that.hScroll = that.options.hScroll && that.maxScrollX < 0;
            that.vScroll = that.options.vScroll && (!that.options.bounceLock && !that.hScroll || that.scrollerH > that.wrapperH);


            offset = that._offset(that.wrapper);
            that.wrapperOffsetLeft = -offset.left;
            that.wrapperOffsetTop = -offset.top;


            that.scroller.style[transitionDuration] = '0';
            that._resetPos(400);
        },

        scrollTo: function (x, y, time, relative) {
            var that = this,
                step = x,
                i, l;

            that.stop();

            if (!step.length) step = [{ x: x, y: y, time: time, relative: relative }];

            for (i=0, l=step.length; i<l; i++) {
                if (step[i].relative) { step[i].x = that.x - step[i].x; step[i].y = that.y - step[i].y; }
                that.steps.push({ x: step[i].x, y: step[i].y, time: step[i].time || 0 });
            }

            that._startAni();
        },

        scrollToElement: function (el, time) {
            var that = this, pos;
            el = el.nodeType ? el : that.scroller.querySelector(el);
            if (!el) return;

            pos = that._offset(el);
            pos.left += that.wrapperOffsetLeft;
            pos.top += that.wrapperOffsetTop;

            pos.left = pos.left > 0 ? 0 : pos.left < that.maxScrollX ? that.maxScrollX : pos.left;
            pos.top = pos.top > that.minScrollY ? that.minScrollY : pos.top < that.maxScrollY ? that.maxScrollY : pos.top;
            time = time === undefined ? m.max(m.abs(pos.left)*2, m.abs(pos.top)*2) : time;

            that.scrollTo(pos.left, pos.top, time);
        },

        scrollToPage: function (pageX, pageY, time) {
            var that = this, x, y;

            time = time === undefined ? 400 : time;

            if (that.options.onScrollStart) that.options.onScrollStart.call(that);


            x = -that.wrapperW * pageX;
            y = -that.wrapperH * pageY;
            if (x < that.maxScrollX) x = that.maxScrollX;
            if (y < that.maxScrollY) y = that.maxScrollY;


            that.scrollTo(x, y, time);
        },

        disable: function () {
            this.stop();
            this._resetPos(0);
            this.enabled = false;

            // If disabled after touchstart we make sure that there are no left over events
            this._unbind(MOVE_EV, window);
            this._unbind(END_EV, window);
            this._unbind(CANCEL_EV, window);
        },

        enable: function () {
            this.enabled = true;
        },

        stop: function () {
            if (this.options.useTransition) this._unbind(TRNEND_EV);
            else cancelFrame(this.aniTime);
            this.steps = [];
            this.moved = false;
            this.animating = false;
        },

        isReady: function () {
            return !this.moved &&  !this.animating;
        }
    };

    function prefixStyle (style) {
        if ( vendor === '' ) return style;

        style = style.charAt(0).toUpperCase() + style.substr(1);
        return vendor + style;
    }

    dummyStyle = null;	// for the sake of it

    if (typeof exports !== 'undefined') exports.iScroll = iScroll;
    else window.iScroll = iScroll;

    (function($){
        if(!$)return;
        var orgiScroll = iScroll,
            id = 0,
            cacheInstance = {};
        function createInstance(el,options){
            var uqid = 'iscroll' + id++;
            el.data('_iscroll_',uqid);
            return cacheInstance[uqid] = new orgiScroll(el[0],options)
        }
        window.iScroll = function(el,options){
            return createInstance($(typeof el == 'string' ? '#' + el : el),options)
        };
        $.fn.iScroll = function(method){
            var resultArr = [];
            this.each(function(i,el){
                if(typeof method == 'string'){
                    var instance = cacheInstance[$(el).data('_iscroll_')],pro;
                    if(instance && (pro = instance[method])){
                        var result = $.isFunction(pro) ? pro.apply(instance, Array.prototype.slice.call(arguments,1)) : pro;
                        if(result !== instance && result !== undefined){
                            resultArr.push(result);
                        }
                    }
                }else{
                    if(!$(el).data('_iscroll_'))
                        createInstance($(el),method)
                }
            });

            return resultArr.length ? resultArr : this;
        }
    })(window.Zepto || null)



})(window, document);
/**
 * Change list
 * 修改记录
 *
 * 1. 2012-08-14 解决滑动中按住停止滚动，松开后被点元素触发点击事件。
 *
 * 具体修改:
 * a. 202行 添加isStopScrollAction: false 给iScroll的原型上添加变量
 * b. 365行 _start方法里面添加that.isStopScrollAction = false; 默认让这个值为false
 * c. 390行 if (x != that.x || y != that.y)条件语句里面 添加了  that.isStopScrollAction = true; 当目标值与实际值不一致，说明还在滚动动画中
 * d. 554行 that.isStopScrollAction || (that.doubleTapTimer = setTimeout(function () {
 *          ......
 *          ......
 *          }, that.options.zoom ? 250 : 0));
 *   如果isStopScrollAction为true就不派送click事件
 *
 *
 * 2. 2012-08-14 给options里面添加speedScale属性，提供外部控制冲量滚动速度
 *
 * 具体修改
 * a. 108行 添加speedScale: 1, 给options里面添加speedScale属性，默认为1
 * b. 798行 speed = m.abs(dist) * this.options.speedScale / time, 在原来速度的基础上*speedScale来改变速度
 *
 * 3. 2012-08-21 修改部分代码，给iscroll_plugin墙用的
 *
 * 具体修改
 * a. 517行  在_pos之前，调用_beforePos,如果里面不返回true,  将不会调用_pos
 *  // internal for header scroll
 *  if (that._beforePos)
 *      that._beforePos(newY, deltaY) && that._pos(newX, newY);
 *  else
 *      that._pos(newX, newY);
 *
 * b. 680行 在滚动结束后调用 _afterPos.
 * // internal for header scroll
 * if (that._afterPos) that._afterPos();
 *
 * c. 106行构造器里面添加以下代码
 * // add var to this for header scroll
 * that.translateZ = translateZ;
 *
 * 为处理溢出
 * _bind 方法
 * destroy 方法
 * 最开头的 _bindArr = []
 *
 */
/**
 * @file GMU定制版iscroll，基于[iScroll 4.2.2](http://cubiq.org/iscroll-4), 去除zoom, pc兼容，snap, scrollbar等功能。同时把iscroll扩展到了Zepto的原型中。
 * @name zepto.iScroll
 * @import core/zepto.js
 * @desc GMU定制版iscroll，基于{@link[http://cubiq.org/iscroll-4] iScroll 4.2.2}, 去除zoom, pc兼容，snap, scrollbar等功能。同时把iscroll扩展到了***Zepto***的原型中。
 */

/**
 * @name iScroll
 * @grammar new iScroll(el,[options])  ⇒ self
 * @grammar $('selecotr').iScroll([options])  ⇒ zepto实例
 * @desc 将iScroll加入到了***$.fn***中，方便用Zepto的方式调用iScroll。
 * **el**
 * - ***el {String/ElementNode}*** iscroll容器节点
 *
 * **Options**
 * - ***hScroll*** {Boolean}: (可选, 默认: true)横向是否可以滚动
 * - ***vScroll*** {Boolean}: (可选, 默认: true)竖向是否可以滚动
 * - ***momentum*** {Boolean}: (可选, 默认: true)是否带有滚动效果
 * - ***checkDOMChanges*** {Boolean, 默认: false}: (可选)每个500毫秒判断一下滚动区域的容器是否有新追加的内容，如果有就调用refresh重新渲染一次
 * - ***useTransition*** {Boolean, 默认: false}: (可选)是否使用css3来来实现动画，默认是false,建议开启
 * - ***topOffset*** {Number}: (可选, 默认: 0)可滚动区域头部缩紧多少高度，默认是0， ***主要用于头部下拉加载更多时，收起头部的提示按钮***
 * @example
 * $('div').iscroll().find('selector').atrr({'name':'aaa'}) //保持链式调用
 * $('div').iScroll('refresh');//调用iScroll的方法
 * $('div').iScroll('scrollTo', 0, 0, 200);//调用iScroll的方法, 200ms内滚动到顶部
 */


/**
 * @name destroy
 * @desc 销毁iScroll实例，在原iScroll的destroy的基础上对创建的dom元素进行了销毁
 * @grammar destroy()  ⇒ undefined
 */

/**
 * @name refresh
 * @desc 更新iScroll实例，在滚动的内容增减时，或者可滚动区域发生变化时需要调用***refresh***方法来纠正。
 * @grammar refresh()  ⇒ undefined
 */

/**
 * @name scrollTo
 * @desc 使iScroll实例，在指定时间内滚动到指定的位置， 如果relative为true, 说明x, y的值是相对与当前位置的。
 * @grammar scrollTo(x, y, time, relative)  ⇒ undefined
 */
/**
 * @name scrollToElement
 * @desc 滚动到指定内部元素
 * @grammar scrollToElement(element, time)  ⇒ undefined
 * @grammar scrollToElement(selector, time)  ⇒ undefined
 */
/**
 * @name scrollToPage
 * @desc 跟scrollTo很像，这里传入的是百分比。
 * @grammar scrollToPage(pageX, pageY, time)  ⇒ undefined
 */
/**
 * @name disable
 * @desc 禁用iScroll
 * @grammar disable()  ⇒ undefined
 */
/**
 * @name enable
 * @desc 启用iScroll
 * @grammar enable()  ⇒ undefined
 */
/**
 * @name stop
 * @desc 定制iscroll滚动
 * @grammar stop()  ⇒ undefined
 */




/*!Extend zepto.ui.js*/
(function(f,c){var b=1,e=function(){},j="<%=name%>-<%=id%>",h=(function(){var n={},o=0,m="GMUWidget"+(+new Date());return function(s,r,t){var p=s[m]||(s[m]=++o),q=n[p]||(n[p]={});!f.isUndefined(t)&&(q[r]=t);f.isNull(t)&&delete q[r];return q[r]}})();f.ui=f.ui||{version:"2.0.5",guid:g,define:function(n,p,o){if(o){p.inherit=o}var m=f.ui[n]=d(function(r,q){var s=k(m.prototype,{_id:f.parseTpl(j,{name:n,id:g()})});s._createWidget.call(s,r,q,m.plugins);return s},p);return i(n,m)},isWidget:function(n,m){return n instanceof (m===c?l:f.ui[m]||e)}};function g(){return b++}function k(m,n){var o={};Object.create?o=Object.create(m):o.__proto__=m;return f.extend(o,n||{})}function d(m,n){if(n){a(m,n);f.extend(m.prototype,n)}return f.extend(m,{plugins:[],register:function(o){if(f.isObject(o)){f.extend(this.prototype,o);return}this.plugins.push(o)}})}function a(m,p){var n=p.inherit||l,o=n.prototype,q;q=m.prototype=k(o,{$factory:m,$super:function(r){var s=o[r];return f.isFunction(s)?s.apply(this,f.slice(arguments,1)):s}});q._data=f.extend({},o._data,p._data);delete p._data;return m}function i(m){f.fn[m]=function(p){var o,q,n=f.slice(arguments,1);f.each(this,function(r,s){q=h(s,m)||f.ui[m](s,f.extend(f.isPlainObject(p)?p:{},{setup:true}));if(f.isString(p)){if(!f.isFunction(q[p])&&p!=="this"){throw new Error(m+"\u7ec4\u4ef6\u6ca1\u6709\u6b64\u65b9\u6cd5")}o=f.isFunction(q[p])?q[p].apply(q,n):c}if(o!==c&&o!==q||p==="this"&&(o=q)){return false}o=c});return o!==c?o:this}}var l=function(){};f.extend(l.prototype,{_data:{status:true},data:function(m,o){var n=this._data;if(f.isObject(m)){return f.extend(n,m)}else{return !f.isUndefined(o)?n[m]=o:n[m]}},_createWidget:function(o,q,m){if(f.isObject(o)){q=o||{};o=c}var r=f.extend({},this._data,q);f.extend(this,{_el:o?f(o):c,_data:r});var p=this;f.each(m,function(u,v){var s=v.apply(p);if(s&&f.isPlainObject(s)){var t=p._data.disablePlugin;if(!t||f.isString(t)&&!~t.indexOf(s.pluginName)){delete s.pluginName;f.each(s,function(w,y){var x;if((x=p[w])&&f.isFunction(y)){p[w]=function(){p[w+"Org"]=x;return y.apply(p,arguments)}}else{p[w]=y}})}}});if(r.setup){this._setup(o&&o.getAttribute("data-mode"))}else{this._create()}this._init();var p=this,n=this.trigger("init").root();n.on("tap",function(s){(s.bubblesList||(s.bubblesList=[])).push(p)});h(n[0],p._id.split("-")[0],p)},_create:function(){},_setup:function(m){},root:function(m){return this._el=m||this._el},id:function(m){return this._id=m||this._id},destroy:function(){var n=this,m;m=this.trigger("destroy").off().root();m.find("*").off();h(m[0],n._id.split("-")[0],null);m.off().remove();this.__proto__=null;f.each(this,function(o){delete n[o]})},on:function(m,n){this.root().on(m,f.proxy(n,this));return this},off:function(m,n){this.root().off(m,n);return this},trigger:function(n,o){n=f.isString(n)?f.Event(n):n;var p=this.data(n.type),m;if(p&&f.isFunction(p)){n.data=o;m=p.apply(this,[n].concat(o));if(m===false||n.defaultPrevented){return this}}this.root().trigger(n,o);return this}})})(Zepto);
/*!Widget slider.js*/
(function(a,b){a.ui.define("slider",{_data:{viewNum:1,imgInit:2,itemRender:null,imgZoom:false,loop:false,stopPropagation:false,springBackDis:15,autoPlay:true,autoPlayTime:4000,animationTime:400,showArr:true,showDot:true,slide:null,slideend:null,index:0,_stepLength:1,_direction:1},_create:function(){var g=this,e=0,d,c=[],f=g.data("content");g._initConfig();(g.root()||g.root(a("<div></div>"))).addClass("ui-slider").appendTo(g.data("container")||(g.root().parent().length?"":document.body)).html('<div class="ui-slider-wheel"><div class="ui-slider-group">'+(function(){if(g.data("itemRender")){var h=g.data("itemRender");while(d=h.call(g,e++)){c.push('<div class="ui-slider-item">'+d+"</div>")}}else{while(d=f[e++]){c.push('<div class="ui-slider-item"><a href="'+d.href+'"><img lazyload="'+d.pic+'"/></a>'+(d.title?"<p>"+d.title+"</p>":"")+"</div>")}}c.push(g.data("loop")?'</div><div class="ui-slider-group">'+c.join("")+"</div></div>":"</div></div>");return c.join("")}()));g._addDots()},_setup:function(g){var e=this,c=e.root().addClass("ui-slider");e._initConfig();if(!g){var d=c.children(),f=a('<div class="ui-slider-group"></div>').append(d.addClass("ui-slider-item"));c.empty().append(a('<div class="ui-slider-wheel"></div>').append(f).append(e.data("loop")?f.clone():""));e._addDots()}else{e.data("loop")&&a(".ui-slider-wheel",c).append(a(".ui-slider-group",c).clone())}},_init:function(){var f=this,d=f.data("index"),c=f.root(),e=a.proxy(f._eventHandler,f);f._setWidth();a(f.data("wheel")).on("touchstart touchmove touchend touchcancel webkitTransitionEnd",e);a(window).on("ortchange",e);a(".ui-slider-pre",c).on("tap",function(){f.pre()});a(".ui-slider-next",c).on("tap",function(){f.next()});f.on("destroy",function(){clearTimeout(f.data("play"));a(window).off("ortchange",e)});f.data("autoPlay")&&f._setTimeout()},_initConfig:function(){var c=this._data;if(c.viewNum>1){c.loop=false;c.showDot=false;c.imgInit=c.viewNum+1}},_addDots:function(){var f=this,c=f.root(),e=a(".ui-slider-item",c).length/(f.data("loop")?2:1),d=[];if(f.data("showDot")){d.push('<p class="ui-slider-dots">');while(e--){d.push("<b></b>")}d.push("</p>")}f.data("showArr")&&(d.push('<span class="ui-slider-pre"><b></b></span><span class="ui-slider-next"><b></b></span>'));c.append(d.join(""))},_setWidth:function(){var s=this,f=s._data,t=s.root(),c=Math.ceil(t.width()/f.viewNum),u=t.height(),n=f.loop,q=a(".ui-slider-item",t).toArray(),g=q.length,p=a(".ui-slider-wheel",t).width(c*g)[0],r=a(".ui-slider-dots b",t).toArray(),e=a("img",t).toArray(),v=e.concat(),d={},m,k,h=f.imgInit||g;f.showDot&&(r[0].className="ui-slider-dot-select");if(f.imgZoom){a(v).on("load",function(){var l=this.height,i=this.width,o=Math.min(l,u),j=Math.min(i,c);if(l/u>i/c){this.style.cssText+="height:"+o+"px;width:"+o/l*i+"px;"}else{this.style.cssText+="height:"+j/i*l+"px;width:"+j+"px"}this.onload=null})}for(m=0;m<g;m++){q[m].style.cssText+="width:"+c+"px;position:absolute;-webkit-transform:translate3d("+m*c+"px,0,0);z-index:"+(900-m);d[m]=n?(m>g/2-1?m-g/2:m):m;if(m<h){k=v.shift();k&&(k.src=k.getAttribute("lazyload"));if(f.loop){k=e[m+g/2];k&&(k.src=k.getAttribute("lazyload"))}}}s.data({root:t[0],wheel:p,items:q,lazyImgs:v,allImgs:e,length:g,width:c,height:u,dots:r,dotIndex:d,dot:r[0]});return s},_eventHandler:function(d){var c=this;switch(d.type){case"touchmove":c._touchMove(d);break;case"touchstart":c._touchStart(d);break;case"touchcancel":case"touchend":c._touchEnd();break;case"webkitTransitionEnd":c._transitionEnd();break;case"ortchange":c._resize.call(c);break}},_touchStart:function(d){var c=this;c.data({pageX:d.touches[0].pageX,pageY:d.touches[0].pageY,S:false,T:false,X:0});c.data("wheel").style.webkitTransitionDuration="0ms"},_touchMove:function(g){var h=this._data,i=h.X=g.touches[0].pageX-h.pageX;if(!h.T){var c=h.index,f=h.length,d=Math.abs(i)<Math.abs(g.touches[0].pageY-h.pageY);h.loop&&(h.index=c>0&&(c<f-1)?c:(c===f-1)&&i<0?f/2-1:c===0&&i>0?f/2:c);d||clearTimeout(h.play);h.T=true;h.S=d}if(!h.S){h.stopPropagation&&g.stopPropagation();g.preventDefault();h.wheel.style.webkitTransform="translate3d("+(i-h.index*h.width)+"px,0,0)"}},_touchEnd:function(){var d=this,e=d._data;if(!e.S){var f=e.springBackDis,c=e.X<=-f?Math.ceil(-e.X/e.width):(e.X>f)?-Math.ceil(e.X/e.width):0;e._stepLength=Math.abs(c);d._slide(e.index+c)}},_slide:function(d,h){var f=this,g=f._data,e=g.length,c=e-g.viewNum+1;if(-1<d&&d<c){f._move(d)}else{if(d>=c){if(!g.loop){f._move(c-(h?2:1));g._direction=-1}else{g.wheel.style.cssText+="-webkit-transition:0ms;-webkit-transform:translate3d(-"+(e/2-1)*g.width+"px,0,0);";g._direction=1;a.later(function(){f._move(e/2)},20)}}else{if(!g.loop){f._move(h?1:0)}else{g.wheel.style.cssText+="-webkit-transition:0ms;-webkit-transform:translate3d(-"+(e/2)*g.width+"px,0,0);";a.later(function(){f._move(e/2-1)},20)}g._direction=1}}return f},_move:function(d){var f=this._data,e=f.dotIndex[d];this.trigger("slide",e);if(f.lazyImgs.length){var c=f.allImgs[d];c&&c.src||(c.src=c.getAttribute("lazyload"))}if(f.showDot){f.dot.className="";f.dots[e].className="ui-slider-dot-select";f.dot=f.dots[e]}f.index=d;f.wheel.style.cssText+="-webkit-transition:"+f.animationTime+"ms;-webkit-transform:translate3d(-"+d*f.width+"px,0,0);"},_transitionEnd:function(){var f=this,g=f._data;f.trigger("slideend",g.dotIndex[g.index]);if(g.lazyImgs.length){for(var e=g._stepLength,d=0;d<e;d++){var c=g.lazyImgs.shift();c&&(c.src=c.getAttribute("lazyload"));if(g.loop){c=g.allImgs[g.index+g.length/2];c&&!c.src&&(c.src=c.getAttribute("lazyload"))}}g._stepLength=1}f._setTimeout()},_setTimeout:function(){var c=this,d=c._data;if(!d.autoPlay){return c}clearTimeout(d.play);d.play=a.later(function(){c._slide.call(c,d.index+d._direction,true)},d.autoPlayTime);return c},_resize:function(){var g=this,h=g._data,e=h.root.offsetWidth/h.viewNum,f=h.length,c=h.items;if(!e){return g}h.width=e;clearTimeout(h.play);for(var d=0;d<f;d++){c[d].style.cssText+="width:"+e+"px;-webkit-transform:translate3d("+d*e+"px,0,0);"}h.wheel.style.removeProperty("-webkit-transition");h.wheel.style.cssText+="width:"+e*f+"px;-webkit-transform:translate3d(-"+h.index*e+"px,0,0);";h._direction=1;g._setTimeout();return g},pre:function(){var c=this;c._slide(c.data("index")-1);return c},next:function(){var c=this;c._slide(c.data("index")+1);return c},stop:function(){var c=this;clearTimeout(c.data("play"));c.data("autoPlay",false);return c},resume:function(){var c=this;c.data("_direction",1);c.data("autoPlay",true);c._setTimeout();return c}})})(Zepto);


/*!Widget calendar.js*/
/**
 * @file 日历组件
 * @name Calendar
 * @desc <qrcode align="right" title="Live Demo">../gmu/_examples/widget/calendar/calendar.html</qrcode>
 * 日历组件, 可以用来给一容器生成日历。
 * @import core/touch.js, core/zepto.ui.js, core/zepto.highlight.js
 */ (function($, undefined) {
	var monthNames = ["01月", "02月", "03月", "04月", "05月", "06月",
			"07月", "08月", "09月", "10月", "11月", "12月"
	],

		dayNames = ["日", "一", "二", "三", "四", "五", "六"],
		offsetRE = /^(\+|\-)?(\d+)(M|Y)$/i,

		//获取月份的天数
		getDaysInMonth = function(year, month) {
			return 32 - new Date(year, month, 32).getDate();
		},

		//获取月份中的第一天是所在星期的第几天
		getFirstDayOfMonth = function(year, month) {
			return new Date(year, month, 1).getDay();
		},

		//格式化数字，不足补零.
		formatNumber = function(val, len) {
			var num = "" + val;
			while (num.length < len) {
				num = "0" + num;
			}
			return num;
		},

		getVal = function(elem) {
			return elem.is('select, input') ? elem.val() : elem.attr('data-value');
		},

		prototype;

	/**
	 * @name $.ui.calendar
	 * @grammar $.ui.calendar(options) ⇒ instance
	 * @grammar calendar(options) ⇒ self
	 * @desc **Options**
	 * - ''date'' {Date|String}: (可选，默认：today) 初始化日期
	 * - ''firstDay'' {Number}: (可选，默认：1)  设置新的一周从星期几开始，星期天用0表示, 星期一用1表示, 以此类推.
	 * - ''minDate'' {Date|String}: (可选，默认：null)  设置可以选择的最小日期
	 * - ''maxDate'' {Date|String}: (可选，默认：null)  设置可以选择的最大日期
	 * - ''swipeable'' {Boolean}: (可选，默认：false)  设置是否可以通过左右滑动手势来切换日历
	 * - ''monthChangeable'' {Boolean}: (可选，默认：false)  设置是否让月份可选择
	 * - ''yearChangeable'' {Boolean}: (可选，默认：false)  设置是否让年份可选择
	 * - ''events'' 所有[Trigger Events](#calendar_triggerevents)中提及的事件都可以在此设置Hander, 如init: function(e){}。
	 *
	 * **Demo**
	 * <codepreview href="../gmu/_examples/widget/calendar/calendar.html">
	 * ../gmu/_examples/widget/calendar/calendar.html
	 * </codepreview>
	 */
	$.ui.define('calendar', {
		_data: {
			date: null, //默认日期
			firstDay: 1, //星期天用0表示, 星期一用1表示, 以此类推.
			maxDate: null, //可以选择的日期范围
			minDate: null,
			swipeable: false,
			monthChangeable: false,
			yearChangeable: false,
			selectYear: null,
			selectYearBefore: null,
			selectYearAfter: null
		},

		_create: function() {
			var el = this.root();

			//如果没有指定el, 则创建一个空div
			el = el || this.root($('<div></div>'));
			el.appendTo(this.data('container') || (el.parent().length ? '' : document.body));
		},

		_init: function() {
			var data = this._data,
				el = this._container || this.root(),
				eventHandler = $.proxy(this._eventHandler, this);

			this.minDate(data.minDate)
				.maxDate(data.maxDate)
				.date(data.date || new Date())
				.refresh();

			el.addClass('ui-calendar')
				.on('click', eventHandler)
				.highlight();

			data.swipeable && el.on('swipeLeft swipeRight', eventHandler);
		},

		_eventHandler: function(e) {
			var data = this._data,
				root = (this._container || this.root()).get(0),
				match,
				target,
				cell,
				date,
				elems;

			switch (e.type) {
				case 'swipeLeft':
				case 'swipeRight':
					return this.switchMonthTo((e.type == 'swipeRight' ? '-' : '+') + '1M');

				case 'change':
					elems = $('.ui-calendar-header .ui-calendar-year, ' +
						'.ui-calendar-header .ui-calendar-month', this._el);

					return this.switchMonthTo(getVal(elems.eq(1)), getVal(elems.eq(0)));

				default:
					//click

					target = e.target;

					if ((match = $(target).closest('.ui-calendar-calendar tbody a', root)) && match.length) {

						e.preventDefault();
						cell = match.parent();

						this._option('selectedDate',
							date = new Date(cell.attr('data-year'), cell.attr('data-month'), match.text()));

						this.trigger('select', [date, $.calendar.formatDate(date), this]);
						this.refresh();
					} else if ((match = $(target).closest('.ui-calendar-prev, .ui-calendar-next', root)) && match.length) {

						e.preventDefault();
						this.switchMonthTo((match.is('.ui-calendar-prev') ? '-' : '+') + '1M');
					}
			}
		},

		/**
		 * @ignore
		 * @name option
		 * @grammar option(key[, value]) ⇒ instance
		 * @desc 设置或获取Option，如果想要Option生效需要调用[Refresh](#calendar_refresh)方法。
		 */
		_option: function(key, val) {
			var data = this._data,
				date, minDate, maxDate;

			//如果是setter
			if (val !== undefined) {

				switch (key) {
					case 'minDate':
					case 'maxDate':
						data[key] = val ? $.calendar.parseDate(val) : null;
						break;

					case 'selectedDate':
						minDate = data.minDate;
						maxDate = data.maxDate;
						val = $.calendar.parseDate(val);
						val = minDate && minDate > val ? minDate : maxDate && maxDate < val ? maxDate : val;
						data._selectedYear = data._drawYear = val.getFullYear();
						data._selectedMonth = data._drawMonth = val.getMonth();
						data._selectedDay = val.getDate();
						break;

					case 'date':
						this._option('selectedDate', val);
						data[key] = this._option('selectedDate');
						break;

					default:
						data[key] = val;
				}

				//标记为true, 则表示下次refresh的时候要重绘所有内容。
				data._invalid = true;

				//如果是setter则要返回instance
				return this;
			}

			return key == 'selectedDate' ? new Date(data._selectedYear, data._selectedMonth, data._selectedDay) : data[key];
		},

		/**
		 * 切换到今天所在月份。
		 * @name switchToToday
		 * @grammar switchToToday() ⇒ instance
		 * @returns {*}
		 */
		switchToToday: function() {
			var today = new Date();
			return this.switchMonthTo(today.getMonth(), today.getFullYear());
		},

		/**
		 * @name switchMonthTo
		 * @grammar switchMonthTo(month, year) ⇒ instance
		 * @grammar switchMonthTo(str) ⇒ instance
		 * @desc 使组件显示某月，当第一参数为str可以+1M, +4M, -5Y, +1Y等等。+1M表示在显示的月的基础上显示下一个月，+4m表示下4个月，-5Y表示5年前
		 */
		switchMonthTo: function(month, year) {
			var data = this._data,
				minDate = this.minDate(),
				maxDate = this.maxDate(),
				offset,
				period,
				tmpDate;

			if ($.isString(month) && offsetRE.test(month)) {
				offset = RegExp.$1 == '-' ? -parseInt(RegExp.$2, 10) : parseInt(RegExp.$2, 10);
				period = RegExp.$3.toLowerCase();
				month = data._drawMonth + (period == 'm' ? offset : 0);
				year = data._drawYear + (period == 'y' ? offset : 0);
			} else {
				month = parseInt(month, 10);
				year = parseInt(year, 10);
			}

			//Date有一定的容错能力，如果传入2012年13月，它会变成2013年1月
			tmpDate = new Date(year, month, 1);

			//不能跳到不可选的月份
			tmpDate = minDate && minDate > tmpDate ? minDate : maxDate && maxDate < tmpDate ? maxDate : tmpDate;

			month = tmpDate.getMonth();
			year = tmpDate.getFullYear();

			if (month != data._drawMonth || year != data._drawYear) {
				this.trigger('monthchange', [
					data._drawMonth = month, data._drawYear = year, this
				]);

				data._invalid = true;
				this.refresh();
			}

			return this;
		},

		/**
		 * @name refresh
		 * @grammar refresh() ⇒ instance
		 * @desc 当修改option后需要调用此方法。
		 */
		refresh: function() {
			var data = this._data,
				el = this._container || this.root(),
				eventHandler = $.proxy(this._eventHandler, this);

			//如果数据没有变化厕不重绘了
			if (!data._invalid) {
				return;
			}

			$('.ui-calendar-calendar td:not(.ui-state-disabled), .ui-calendar-header a', el).highlight();
			$('.ui-calendar-header select', el).off('change', eventHandler);
			el.empty().append(this._generateHTML());
			$('.ui-calendar-calendar td:not(.ui-state-disabled), .ui-calendar-header a', el).highlight('ui-state-hover');
			$('.ui-calendar-header select', el).on('change', eventHandler);
			data._invalid = false;
			return this;
		},

		/**
		 * @desc 销毁组件。
		 * @name destroy
		 * @grammar destroy()  ⇒ instance
		 */
		destroy: function() {
			var el = this._container || this.root(),
				eventHandler = this._eventHandler;

			$('.ui-calendar-calendar td:not(.ui-state-disabled)', el).highlight();
			$('.ui-calendar-header select', el).off('change', eventHandler);
			return this.$super('destroy');
		},

		/**
		 * 重绘表格
		 */
		_generateHTML: function() {
			var data = this._data,
				drawYear = data._drawYear,
				drawMonth = data._drawMonth,
				tempDate = new Date(),
				today = new Date(tempDate.getFullYear(), tempDate.getMonth(),
					tempDate.getDate()),

				minDate = this.minDate(),
				maxDate = this.maxDate(),
				selectedDate = this.selectedDate(),
				html = '',
				i,
				j,
				firstDay,
				day,
				leadDays,
				daysInMonth,
				rows,
				printDate;

			firstDay = (isNaN(firstDay = parseInt(data.firstDay, 10)) ? 0 : firstDay);

			html += this._renderHead(data, drawYear, drawMonth, minDate, maxDate) +
				'<table  class="ui-calendar-calendar"><thead><tr>';

			for (i = 0; i < 7; i++) {
				day = (i + firstDay) % 7;

				html += '<th' + ((i + firstDay + 6) % 7 >= 5 ?

				//如果是周末则加上ui-calendar-week-end的class给th
				' class="ui-calendar-week-end"' : '') + '>' +
					'<span>' + dayNames[day] + '</span></th>';
			}

			//添加一个间隙，样式需求
			html += '</thead></tr><tbody><tr class="ui-calendar-gap">' +
				'<td colspan="7">&#xa0;</td></tr>';

			daysInMonth = getDaysInMonth(drawYear, drawMonth);
			leadDays = (getFirstDayOfMonth(drawYear, drawMonth) - firstDay + 7) % 7;
			rows = Math.ceil((leadDays + daysInMonth) / 7);
			printDate = new Date(drawYear, drawMonth, 1 - leadDays);

			for (i = 0; i < rows; i++) {
				html += '<tr>';

				for (j = 0; j < 7; j++) {
					html += this._renderDay(j, printDate, firstDay, drawMonth, selectedDate, today, minDate, maxDate);
					printDate.setDate(printDate.getDate() + 1);
				}
				html += '</tr>';
			}
			html += '</tbody></table>';
			return html;
		},

		_renderHead: function(data, drawYear, drawMonth, minDate, maxDate) {
			var html = '<div class="ui-calendar-header">',

				//上一个月的最后一天
				lpd = new Date(drawYear, drawMonth, -1),

				//下一个月的第一天
				fnd = new Date(drawYear, drawMonth + 1, 1),
				i,
				max;

			html += '<a class="ui-calendar-prev' + (minDate && minDate > lpd ?
				' ui-state-disable' : '') + '" href="#">&lt;&lt;</a><div class="ui-calendar-title">';

			if (data.yearChangeable) {
				html += '<select class="ui-calendar-year">';

				if (this._data.selectYearBefore !== null || this._data.selectYearAfter !== null) {
					var today = new Date();
					var y = today.getFullYear();
					for (i = y - parseInt(this._data.selectYearBefore), max = y + parseInt(this._data.selectYearAfter); i < max; i++) {
						html += '<option value="' + i + '" ' + (i == drawYear ?
							'selected="selected"' : '') + '>' + i + '年</option>';
					}
				} else {
					for (i = Math.max(1970, drawYear - 10), max = i + 20; i < max; i++) {
						html += '<option value="' + i + '" ' + (i == drawYear ?
							'selected="selected"' : '') + '>' + i + '年</option>';
					}
				}

				html += '</select>';
			} else {
				html += '<span class="ui-calendar-year" data-value="' + drawYear + '">' + drawYear + '年' + '</span>';
			}

			if (data.monthChangeable) {
				html += '<select class="ui-calendar-month">';

				for (i = 0; i < 12; i++) {
					html += '<option value="' + i + '" ' + (i == drawMonth ?
						'selected="selected"' : '') + '>' + monthNames[i] + '</option>';
				}
				html += '</select>';
			} else {
				html += '<span class="ui-calendar-month" data-value="' + drawMonth + '">' + monthNames[drawMonth] + '</span>';
			}

			html += '</div><a class="ui-calendar-next' + (maxDate && maxDate < fnd ?
				' ui-state-disable' : '') + '" href="#">&gt;&gt;</a></div>';
			return html;
		},

		_renderDay: function(j, printDate, firstDay, drawMonth, selectedDate, today, minDate, maxDate) {

			var otherMonth = (printDate.getMonth() !== drawMonth),
				unSelectable;

			unSelectable = otherMonth || (minDate && printDate < minDate) || (maxDate && printDate > maxDate);

			return "<td class='" + ((j + firstDay + 6) % 7 >= 5 ? "ui-calendar-week-end" : "") + // 标记周末

			(unSelectable ? " ui-calendar-unSelectable ui-state-disabled" : "") + //标记不可点的天

			(otherMonth || unSelectable ? '' : (printDate.getTime() === selectedDate.getTime() ? " ui-calendar-current-day" : "") + //标记当前选择
			(printDate.getTime() === today.getTime() ? " ui-calendar-today" : "") //标记今天
			) + "'" +

			(unSelectable ? "" : " data-month='" + printDate.getMonth() + "' data-year='" + printDate.getFullYear() + "'") + ">" +

			(otherMonth ? "&#xa0;" : (unSelectable ? "<span class='ui-state-default'>" + printDate.getDate() + "</span>" :
				"<a class='ui-state-default" + (printDate.getTime() === today.getTime() ? " ui-state-highlight" : "") + (printDate.getTime() === selectedDate.getTime() ? " ui-state-active" : "") +
				"' href='#'>" + printDate.getDate() + "</a>")) + "</td>";
		}
	});

	prototype = $.ui.calendar.prototype;

	//添加更直接的option修改接口
	$.each(['maxDate', 'minDate', 'date', 'selectedDate'], function(i, name) {
		prototype[name] = function(val) {
			return this._option(name, val);
		}
	});

	//补充注释

	/**
	 * @name maxDate
	 * @grammar maxDate([value]) ⇒ instance
	 * @desc 设置或获取maxDate，如果想要Option生效需要调用[Refresh](#calendar_refresh)方法。
	 */

	/**
	 * @name minDate
	 * @grammar minDate([value]) ⇒ instance
	 * @desc 设置或获取minDate，如果想要Option生效需要调用[Refresh](#calendar_refresh)方法。
	 */

	/**
	 * @name date
	 * @grammar date([value]) ⇒ instance
	 * @desc 设置或获取当前date，如果想要Option生效需要调用[Refresh](#calendar_refresh)方法。
	 */

	/**
	 * @name date
	 * @grammar date([value]) ⇒ instance
	 * @desc 设置或获取当前选中的日期，如果想要Option生效需要调用[Refresh](#calendar_refresh)方法。
	 */


	//@todo 支持各种格式
	//开放接口，如果现有格式不能满足需求，外部可以通过覆写一下两个方法
	$.calendar = {

		/**
		 * 解析字符串成日期格式对象。目前支持yyyy-mm-dd格式和yyyy/mm/dd格式。
		 * @name $.calendar.parseDate
		 * @grammar $.calendar.parseDate( str ) ⇒ Date
		 */
		parseDate: function(obj) {
			var dateRE = /^(\d{4})(?:\-|\/)(\d{1,2})(?:\-|\/)(\d{1,2})$/;
			return $.isDate(obj) ? obj : dateRE.test(obj) ? new Date(parseInt(RegExp.$1, 10), parseInt(RegExp.$2, 10) - 1, parseInt(RegExp.$3, 10)) : null;
		},

		/**
		 * 格式化日期对象为字符串, 输出格式为yyy-mm-dd
		 * @name $.calendar.formatDate
		 * @grammar $.calendar.formatDate( date ) ⇒ String
		 */
		formatDate: function(date) {
			return date.getFullYear() + '-' + formatNumber(date.getMonth() + 1, 2) + '-' + formatNumber(date.getDate(), 2);
		}
	}

	/**
	 * @name Trigger Events
	 * @theme event
	 * @desc 组件内部触发的事件
	 *
	 * ^ 名称 ^ 处理函数参数 ^ 描述 ^
	 * | init | event | 组件初始化的时候触发，不管是render模式还是setup模式都会触发 |
	 * | select | event, date, dateStr, ui | 选中日期的时候触发 |
	 * | monthchange | event, month, year, ui | 当当前现实月份发生变化时触发 |
	 * | destroy | event | 组件在销毁的时候触发 |
	 */

})(Zepto);