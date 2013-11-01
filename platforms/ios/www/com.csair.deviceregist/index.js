var isUpdate = false;
document.addEventListener("deviceready", function(){
	queryAndFillDeviceInfo();
	$("#submitBtn").click(function(){
		submit();
	});
}, false);

function fillId(id){
	$("#identifier").val(id);
}

function queryAndFillDeviceInfo(){
	if(cordova && cordova.exec){
		cordova.exec(
			function(data){
				if(data){
					var inputs = $("input");
					for(var i = 0; i < inputs.length; i++){//填充数据
						var key = inputs[i].name;
						inputs[i].value = data[key];
					}
					isUpdate = true;
				}else{
					isUpdate = false;
				}
			}, 
			function(err) {
        	}
        , "DeviceRegister", "queryDevcieInfo", []);
	}
}


function submit(){
	var me = this;
	if(cordova &&cordova.exec){
		var submitType = "submitInfo";//默认新增
		if(isUpdate){
			submitType = "updateDevice";
		}
		var inputs = $("input");
		var json = {};//传给客户端的参数是json
		for(var i = 0; i < inputs.length; i++){
			var value = inputs[i].value;
			var key = inputs[i].name;
			if(!value){  //替换null或者undefined
				value = "";
			}
			json[key] = value;//组装数据
		}
		cordova.exec(
			function(){	
				alert("注册成功"); 
			}, 
			function(err) {
				alert("提交失败,请检查网络连接！");
        	}
        , "DeviceRegister", submitType, [JSON.stringify(json)]);
	}
}
