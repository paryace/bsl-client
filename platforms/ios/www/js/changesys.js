var preSelected;
var changesys = {

    sysList:[],
    target:"",
    el:null,

    initialize:function(){
        // document.addEventListener('deviceready', this.onDeviceReady, false);
        this.onDeviceReady();
        this.fitViewPort();
    },
    onDeviceReady:function(){
        // this.getSysInfo(this.bindEvents);
        console.log("initialize");
        changesys.onGoingIntoIndex();
    },
    bindEvents:function(){
        console.log("bind event");
        changesys.initLoginWindow(changesys.target);
        $("#title").bind("click",function(){
            changesys.getSysInfo();
        });
        // changesys.onGoingIntoIndex();
    },
    fitViewPort:function(){
        var mviewport = $("meta[name=viewport]")[0];
        var height = Math.abs(window.orientation/90)==1?window.screen.availWidth:window.screen.availHeight;
        mviewport.setAttribute("content",mviewport.getAttribute("content")+",height="+height+"px");
    },
    //target是selector表达式
    initLoginWindow:function(target){
        $.ajax({
            url : "../changesys_window.html",
            success : function(changesys_window) {
                $(target).append(changesys_window);
                changesys.el = $("#change_sys_login_wrapper");
            }
        }); 
    },
    disableEvents:function(){
        $("#title").unbind("click");
    },
    getSysInfo:function(callback){
        console.log("get system info");
        if(this.hasCordova()){
            cordova.exec(function(data) {   //需要弹框登陆
                console.log(data);
                console.log("need show window");
                data = JSON.parse(data);
                changesys.showLoginView(data.sysId,data.sysName);
                if(callback)
                    callback();
            }, function(data) {              //不需要弹框登陆
                console.log(data);
                alert("登陆成功!");
            }, "ExtroSystem", "listAllExtroSystem", []);
        }
    },
    hasCordova:function(){
        if(cordova && cordova.exec){
            return true;
        }else{
            console.log("请检查phonegap配置");
            return false;
        }
    },
    //显示登陆框
    showLoginView:function(sysId,title){
        console.log("show login view");
        cordova.exec(function(data) {
            console.log("right window hided");
        }, function(err) {
            console.log("right window not hided");
        }, "ExtroSystem", "dismissRightView", []);

        $("#change_sys_login_title").html("登陆"+title);

        // $("#username").click();
        changesys.showWindow();
        $("#change_sys_submit").unbind("click");
        $("#change_sys_submit").bind("click",function(){
            console.log("提交登陆信息");
            // $("#change_sys_submit").html("取消");
            var username = $("#username").val();
            var password = $("#password").val();
            console.log("username:"+username+",password:"+password+",sysId:"+sysId);
            if(username == "" || password == ""){
                navigator.notification.alert( 
                    "账号和密码不能为空",  // 显示信息 
                    null,         // 警告被忽视的回调函数 
                    '提示',            // 标题 
                    '确定'                  // 按钮名称 
                ); 
                return;
            }
            cordova.exec(function(data) {
                data = $.parseJSON(data);
                console.log(data);
                changesys.onLoginSuccess();
            }, function(err) {
                err = $.parseJSON(err);
                console.log(err);
                changesys.onLoginFail();
            }, "ExtroSystem", "login", [username, password, sysId]);
        });

        $("#change_sys_cancel").unbind("click");
        $("#change_sys_cancel").bind("click",function(){
             console.log("关闭窗口");
             
             $("#wrapper").click();
             $("#sysSelect").val(preSelected);
             changesys.hideWindow();
        });
        $("#username").focus();
    },
    showWindow:function(){
        $("#change_sys_login_wrapper").show();
    },
    hideWindow:function(){
        $("#change_sys_login_wrapper").find("input").val("");
        $("#change_sys_login_wrapper").hide();
        $(changesys.el).trigger("close");
    },
    //登陆成功
    onLoginSuccess:function(sysName){
        console.log("login success");
    },
    //取消登陆
    onLoginCanceled:function(){
        console.log("canceled login");
        cordova.exec(function(data) {
                
        }, function(err) {
        }, "ExtroSystem", "cancel", []);
    },
    //登陆失败
    onLoginFail:function(){
        console.log("login failed");
    },
    //跳转到模块管理页面时调用
    onGoingIntoManage:function(){
        //切换标题到管理,取消title的点击事件
        $("#title").html("模块管理");
        $("#triangle").hide();
        changesys.disableEvents();
    },
    //跳转到首页时调用
    onGoingIntoIndex:function(){
        //切换标题到主页,激活title的点击事件
        cordova.exec(function(data) { 
            // console.log(data);
            data = JSON.parse(data);
            $("#title").html(data.sysName);
            $("#triangle").show();
            changesys.bindEvents();
        }, function(data) { 
        }, "ExtroSystem", "getCurrSystem", []);
    }
}
// changesys.initialize();