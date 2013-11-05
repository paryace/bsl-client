document.addEventListener("deviceready", function(){
	queryAndFillDeviceInfo();
	$("#submitBtn").click(function(){
		console.info("submit");
		submit();
	});
	$("#cancelBtn").click(function(){
		console.info("cancel");
		cancel();
	});
	//testData();
}, false);

//测试用
function testData(){
	$("input[name=staffCode]").val("743337");
	$("input[name=name]").val("测试数据");
	$("input[name=dept]").val("测试部门");
	$("input[name=email]").val("test@163.com");
	$("input[name=telPhone]").val("10320312321");
	$("input[name=deviceSrc]").val("公司");
}

function fillId(id){
	$("#identifier").val(id);
}

function queryAndFillDeviceInfo(){
	console.log("查询注册信息");
	if(cordova && cordova.exec){
		cordova.exec(
			function(data){
				console.log("查询成功");
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
				console.log("查询失败");
        	}
        , "DeviceRegister", "queryDevcieInfo", []);
	}
}


function submit(){
	var me = this;
	if(cordova &&cordova.exec){
		var submitType = "submitInfo";//默认新增
		// if(isUpdate){
		// 	submitType = "updateDevice";
		// }
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


function cancel(){
	if(cordova &&cordova.exec){
		cordova.exec(
				function(){
				}, 
				function(err) {
	        	}
	        , "DeviceRegister", "redirectMain", []);
	}
}

function fillData(data){
	data = JSON.parse(data);
	var inputs = $("input");
	for(var i = 0; i < inputs.length; i++){
		var input = inputs[i];
		if(data[input.name] && data[input.name] != null){
			$(input).val(data[input.name]);
		}
	}
}