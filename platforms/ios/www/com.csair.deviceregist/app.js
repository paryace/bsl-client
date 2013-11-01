define(['zepto', 'backbone', 'com.csair.deviceregist/router'], function($, Backbone, Router){

        var init = function(){

            var router = new Router();
            var rootPath = window.location.pathname.substr(0, window.location.pathname.lastIndexOf('/'));
            Backbone.history.start({pushState: false, root: rootPath});
            // alert(document.location.pathname);
            Backbone.history.navigate('com.csair.deviceregist/', {trigger: true});
            // Backbone.history.navigate(document.location.pathname, {trigger: true});
        };
 
        return {
            initialize: init
        };
});