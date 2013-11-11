var me;
var preSelected;
var changesys = {
    initialize:function(){
        me = this;
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    onDeviceReady:function(){
        // this.getSysInfo(this.bindEvents);
        me.bindEvents();
    },
    bindEvents:function(){
        $("#title").bind("click",function(){
            $("#sysSelect").focus();
            preSelected = $("#sysSelect").val();
        });
        
        $("#sysSelect").bind("change",function(){
            me.showLoginView(this.value);
        })
    },
    disableEvents:function(){
        $("#title").unbind("click");
        $("#sysSelect").unbind("change");
    },
    getSysInfo:function(callback){
        if(this.hasCordova()){
            cordova.exec(function(data) {
                callback();
                var sysList = [];
                //清空选项
                $("#sysSelect").html("");
                //插入选项
                var option = "";
                for(var i = 0; i < sysList.length; i++){
                     option += "<option>"+sysList[i]+"</option>";
                }
                $("#sysSelect").html(option);
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
    showLoginView:function(title){
        $("#change_sys_login_title").html("登陆"+title);

        // $("#username").click();

        $("#change_sys_login_wrapper").show();
        $("#change_sys_submit").unbind("click");
        $("#change_sys_submit").bind("click",function(){
            console.log("提交登陆信息");
            $("#change_sys_submit").html("取消");
            me.onLoginSuccess();
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