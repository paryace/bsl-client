var preSelected;
var changesys = {

    sysList:[],

    initialize:function(){
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    onDeviceReady:function(){
        // this.getSysInfo(this.bindEvents);
        changesys.getSysInfo(changesys.bindEvents);
        // changesys.bindEvents();
    },
    bindEvents:function(){
        $("#title").bind("click",function(){
            $("#sysSelect").focus();
            preSelected = $("#sysSelect").val();
        });
        
        $("#sysSelect").bind("change",function(e){
            var sysId = "";
            var options = $("#sysSelect").find("option")
            for(var i = 0; i < options.length; i++){
                var option = $(options[i]);
                if(option.html() == this.value){
                    sysId = option.attr("data-sysid");
                }
            }
            changesys.showLoginView(sysId,this.value);
        })
    },
    disableEvents:function(){
        $("#title").unbind("click");
        $("#sysSelect").unbind("change");
    },
    getSysInfo:function(callback){
        if(this.hasCordova()){
            cordova.exec(function(data) {
                // var sysList = ["南航统一移动应用","OA验证"];
                var sysList = JSON.parse(data);
                changesys.sysList = sysList;
                //清空选项
                $("#sysSelect").html("");
                //插入选项
                var option = "";
                var currSysName = "";
                for(var i = 0; i < sysList.length; i++){
                     option += "<option data-sysid='"+sysList[i].sysId+"'>"+sysList[i].sysName+"</option>";
                     if(sysList[i].curr){
                        currSysName = sysList[i].sysName;
                     }
                }
                $("#title").html(currSysName);
                $("#sysSelect").html(option);
                $("#sysSelect").val(currSysName);
                callback();
            }, function(err) {
                alert(err);
            }, "ExtroSystem", "listAllExtroSystem", []);
        }
    },
    hasCordova:function(){
        if(cordova && cordova.exec){
            return true;
        }else{
            alert("请检查phonegap配置");
            return false;
        }
    },
    //显示登陆框
    showLoginView:function(sysId,title){
        $("#change_sys_login_title").html("登陆"+title);

        // $("#username").click();

        $("#change_sys_login_wrapper").show();
        $("#change_sys_submit").unbind("click");
        $("#change_sys_submit").bind("click",function(){
            console.log("提交登陆信息");
            $("#change_sys_submit").html("取消");
            var username = $("#username").val();
            var password = $("#password").val();
            // cordova.exec(function(data) {
            //     data = $.parseJSON(data);
            //     alert(data);
            //     changesys.onLoginSuccess();
            // }, function(err) {
            //     err = $.parseJSON(err);
            //     alert(err);
            //     changesys.onLoginFail();
            // }, "CubeLogin", "login", [username, password]);
        });

        $("#change_sys_cancel").unbind("click");
        $("#change_sys_cancel").bind("click",function(){
             console.log("关闭窗口");
             $("#change_sys_login_wrapper").find("input").val("");
             $("#wrapper").click();
             $("#sysSelect").val(preSelected);
             $("#change_sys_login_wrapper").hide();
        });
    },
    //登陆成功
    onLoginSuccess:function(sysName){
       $("#title").html(sysName+"▼");
       $("#change_sys_login_wrapper").hide();
    },
    //取消登陆
    onLoginCanceled:function(){
        $("#change_sys_submit").html("提交");
        cordova.exec(function(data) {
                
            }, function(err) {
                alert(err);
            }, "CubeLogin", "cancelLogin", []);
    },
    //登陆失败
    onLoginFail:function(){
        $("#change_sys_submit").html("提交");
    }
}

changesys.initialize();