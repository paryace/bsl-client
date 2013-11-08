var me;
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
                     })
    
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
        callback();
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
showLoginView:function(title){
    $("#change_sys_login_title").html("登陆"+title);

    // $("#username").click();

    $("#change_sys_login_wrapper").show();
    $("#change_sys_submit").unbind("click");
    $("#change_sys_submit").bind("click",function(){
        console.log("提交登陆信息")
    });
    $("#change_sys_cancel").unbind("click");
    $("#change_sys_cancel").bind("click",function(){
         console.log("关闭窗口");
         $("#change_sys_login_wrapper").find("input").val("");
         $("#change_sys_login_wrapper").hide();
    })
}
}

changesys.initialize();