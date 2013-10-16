/**
 * 实现移动运行网自动重新登录
 */
define(['zepto'], function($){

        var relogin = {
            ajax: function() {
            //Todo
                console.log(arguments);
                

                var error = arguments[0].error;
                var argumentsRelogin = arguments[0];
                arguments[0].error = function(we, wxhr, wtype) {
                    console.log('--------error--------')
                    console.log(arguments);
                    if($(we.response).find('div.errorPanel').length>0){
                        error.call(we, wxhr, wtype);
                        return;
                    }
                    var username = window.localStorage['username'];
                    var password = window.localStorage['password'];
                    $.ajax({
                        timeout: 2000 * 1000,
                        url: host.loginUrl + "j_spring_security_check",
                        type: "post",
                        data: {
                            'username': username,
                            'password': password,
                            'loginFrom': 'web'
                        },
                        dataType: "json",
                        success: function(res, textStatus, jqXHR) {
                            if (res.login === true) {
                                window.localStorage['socUserInfo'] = JSON.stringify(res);
                                $.ajax(argumentsRelogin);
                            } else {

                            }


                            console.info(res);
                        },
                        error: function(e, xhr, type) {
                            error.call(e, xhr, type);
                        }
                    });
                }



                $.ajax(arguments[0]);
            }
        }

	return relogin;
});