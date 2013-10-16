define(['text!com.csair.base/demoIndex.html', 'com.csair.base/urlConfig'], function(demoIndexTemplate, UrlConfig) {

    var View = Piece.View.extend({

        id: 'detailview',

        events: {
            // "click #flightDynamic": "gotoFlightDynamic",
            // "click #aircrewQuery": "gotoAircrewQuery",
            // "click #crewmen": "gotoCrewmen",
            // "click #safe": "gotoSafe",
            // "click #application": "gotoApplication",
            // "click #airport": "gotoAirport",
            // "click #leading": "gotoLeading",
            // "click #todo": "gotoTodo",
            // "click #message": "gotoMessage",
            // "click #personal": "gotoPersonal",
            // "click #newsletter": "gotoNewsletter",
            // "click #performance": "gotoPerformance",
            // "click #suggestions": "gotoSuggestions",
            // "click #wiki": "gotoWiki",
            // "click #notification": "gotoNotification",
            // "click #overview": "gotoOverview",
            // "click #announcement": "gotoAnnouncement"
            "click #login": 'goLogin2',
            "click #logout": 'goLogout'



        },

        bindings: {

            // "Segment:change io": "onIOChange",
            // "List:select flightstatus-list": "onItemSelect"
        },

        onShow: function() {

        },

        goLogout: function() {
            $.ajax({
                timeout: 2000 * 1000,
                url: UrlConfig.login.logout, //'http://10.103.124.106:8088/opws-mobile-web/j_spring_security_logout',
                type: "post",
                data: {
                    // 'username': $("#username").val(),
                    // 'password': $("#password").val()
                },
                dataType: "json",
                success: function(res, textStatus, jqXHR) {


                    console.info(res);
                    if (res.login === true) {
                        new Piece.Toast("登出成功！");
                        console.log('列表数据加载成功：' + textStatus + " response:[" + res + "]");
                 

                    } else {
 
                    }


                   
                },
                error: function(e, xhr, type) {

                    new Piece.Toast("网络异常,登录失败");

                    console.error('列表数据加载失败：' + e + "/" + type + "/" + xhr);

                }
            });

        },
         goLogin: function() {
            var username = $("#username").val();
            var password = $("#password").val();
            $.ajax({
                timeout: 2000 * 1000,
                url: UrlConfig.login.login, //'http://10.103.124.106:8088/opws-mobile-web/j_spring_security_check',
                type: "post",
                data: {
                    'username': $("#username").val(),
                    'password': $("#password").val(),
					'loginFrom': 'web'
                },
                dataType: "json",
                success: function(res, textStatus, jqXHR) {
                    if (res.login === true) {
                        new Piece.Toast("登录成功！");
                        console.log('列表数据加载成功：' + textStatus + " response:[" + res + "]");
                        Piece.Store.saveObject("socUserInfo", res);
                        window.localStorage["username"] = username;
                        window.localStorage["password"] = password;


                    } else {

                        new Piece.Toast("登录失败,请检查用户名或密码是否正确");
                    }


                    console.info(res);
                },
                error: function(e, xhr, type) {

                    new Piece.Toast("网络异常,登录失败");

                    console.error('列表数据加载失败：' + e + "/" + type + "/" + xhr);

                }
            });

        },


        goLogin2: function() {
            $.ajax({
                timeout: 2000 * 1000,
                url: 'http://183.233.189.114:18860/system/api/system/mobile/accounts/login', //'http://10.103.124.106:8088/opws-mobile-web/j_spring_security_check',
                type: "post",
                data: {
                    'appKey': 'cbec6ab6c3dbca2fe1286f37de0a30e0',
                    'username': '203192',
                    'password': 'cz203192'
                },
                dataType: "json",
                success: function(res, textStatus, jqXHR) {
                    if (res.result === true) {
                        new Piece.Toast("登录成功！");
                        console.log('列表数据加载成功：' + textStatus + " response:[" + res + "]");
                        Piece.Store.saveObject("socUserInfo", res);


                    } else {

                        new Piece.Toast("登录失败,请检查用户名或密码是否正确");
                    }


                    console.info(res);
                },
                error: function(e, xhr, type) {

                    new Piece.Toast("网络异常,登录失败");

                    console.error('列表数据加载失败：' + e + "/" + type + "/" + xhr);

                }
            });

        },

        render: function() {
            $(this.el).html(demoIndexTemplate);


            Piece.View.prototype.render.call(this);
            return this;
        },

        gotoFlightDynamic: function() {
            window.location = '../com.csair.dynamic/index.html';
        },

        gotoAircrewQuery: function() {
            window.location = '../com.csair.aircrew/index.html';
        },


        gotoCrewmen: function() {
            window.location = '../com.csair.crewmen/index.html';
        },

        gotoSafe: function() {
            window.location = '../com.csair.safe/index.html';
        },

        gotoApplication: function() {
            window.location = '../com.csair.application/index.html';
        },

        gotoAirport: function() {
            window.location = '../com.csair.airport/index.html';
        },

        gotoLeading: function() {
            window.location = '../com.csair.leading/index.html';
        },

        gotoTodo: function() {
            window.location = '../com.csair.todo/index.html';
        },

        gotoMessage: function() {
            window.location = '../com.csair.message/index.html';
        },

        gotoPersonal: function() {
            window.location = '../com.csair.personal/index.html';
        },

        gotoNewsletter: function() {
            window.location = '../com.csair.newsletter/index.html';
        },

        gotoPerformance: function() {
            window.location = '../com.csair.performance/index.html';
        },

        gotoSuggestions: function() {
            window.location = '../com.csair.suggestions/index.html';
        },

        gotoWiki: function() {
            window.location = '../com.csair.wiki/index.html';
        },

        gotoNotification: function() {
            window.location = '../com.csair.notification/index.html';
        },

        gotoOverview: function() {
            window.location = '../com.csair.overview/index.html';
        },

        gotoAnnouncement: function() {
            window.location = '../com.csair.announcement/index.html';
        }



    });

    return View;
});