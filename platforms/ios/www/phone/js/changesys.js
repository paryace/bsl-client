var preSelected;
var changesys = {

    sysList:[],

    initialize:function(){
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    onDeviceReady:function(){
        // this.getSysInfo(this.bindEvents);
        console.log("initialize");
        cordova.exec(function(data) { 
            // alert(data);
            data = JSON.parse(data);
            $("#title").html(data.sysName);
        }, function(data) {              //不需要登陆
            console.log(data);
        }, "ExtroSystem", "getCurrSystem", []);

        changesys.bindEvents();
    },
    bindEvents:function(){
        console.log("bind event");
        $("#title").bind("click",function(){
            changesys.getSysInfo();
        });
    },
    disableEvents:function(){
        $("#title").unbind("click");
        $("#sysSelect").unbind("change");
    },
    getSysInfo:function(callback){
        console.log("get system info");
        if(this.hasCordova()){
            cordova.exec(function(data) {   //需要弹框登陆
                // var sysList = ["南航统一移动应用","OA验证"];
                console.log(data);
                console.log("need show window");
                data = JSON.parse(data);
                changesys.showLoginView(data.sysId,data.sysName);
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
        $("#change_sys_login_title").html("登陆"+title);

        // $("#username").click();

        $("#change_sys_login_wrapper").show();
        $("#change_sys_submit").unbind("click");
        $("#change_sys_submit").bind("click",function(){
            console.log("提交登陆信息");
            // $("#change_sys_submit").html("取消");
            var username = $("#username").val();
            var password = $("#password").val();
            console.log("username:"+username+",password:"+password+",sysId:"+sysId);
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
             $("#change_sys_login_wrapper").find("input").val("");
             $("#wrapper").click();
             $("#sysSelect").val(preSelected);
             $("#change_sys_login_wrapper").hide();
        });
        $("#username").focus();
    },
    //登陆成功
    onLoginSuccess:function(sysName){
        console.log("login success");
       $("#title").html(sysName+"▼");
       $("#change_sys_login_wrapper").hide();
    },
    //取消登陆
    onLoginCanceled:function(){
        console.log("canceled login");
        // $("#change_sys_submit").html("提交");
        cordova.exec(function(data) {
                
        }, function(err) {
        }, "ExtroSystem", "cancel", []);
    },
    //登陆失败
    onLoginFail:function(){
        console.log("login failed");
        // $("#change_sys_submit").html("提交");
    }
}

changesys.initialize();