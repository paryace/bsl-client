document.addEventListener("deviceready", function(){
     console.log("ready");
	//激活单选框
	$("input[name=deviceSrc]").click();
	//查询设备注册数据并填好
	queryAndFillDeviceInfo();
	$("#submitBtn").click(function(){
		console.info("submit");
		submit();
	});
	$("#cancelBtn").click(function(){
		console.info("cancel");
		cancel();
	});
	

	$(".btn").bind("touchstart",function(){
		$(this).addClass("active");
	})
	$(".btn").bind("touchend",function(){
		$(this).removeClass("active");
	})
    console.log("ready end");
	// testData();
}, false);

function testPhone(phoneNum){
	var pat = /^([0-9-\s])+$/g;
	var value = $(this).val();
	return pat.test(phoneNum);
}

function updateMeta()
{

    var meta = document.getElementsByTagName('meta');
    for(var i=0;i<meta.length;i++){
        if(meta[i].getAttribute('name') == 'viewport')
        {
            var content = meta[i].getAttribute('content');
            content += ',width=400';
            meta[i].setAttribute('content',content);
        }
    }
}


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
                    //安卓是在这里如,传入object,ios是直接调用fillData
                    // data = JSON.stringify(data);
                    $("#registInfo").html("您的设备已注册");
					fillData(data);
				    isUpdate = true;
				}else{
					$("#registInfo").html("您的设备未进行注册");
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
		
		var inputs = $("input[type=text]");
		var labels = $(".cube-form-label")
		var json = {};//传给客户端的参数是json
		for(var i = 0; i < inputs.length; i++){
			var value = $(inputs[i]).val();
			var key = inputs[i].name;
			if(!value || value == ""){  //替换null或者undefined
				// console.log(inputs[i].placeholder.split(",")[0]);
				navigator.notification.alert( 
		           	//inputs[i].placeholder.split(",")[0],  // 显示信息
		            "请填写" + $(labels[i]).html().split(":")[0], 
		            null,         // 警告被忽视的回调函数 
		            '提示',            // 标题 
		            '确定'                  // 按钮名称 
		        ); 
				return;
			}
			json[key] = value;//组装数据
		}
		var id = $("#identifier").val();
		if(id && id != ""){
			json["id"]= id;
		}
		var radios = $("input[name=deviceSrc]");
	    for(var i = 0; i <radios.length; i++){
	    	if(radios[i].checked){
	    		json["deviceSrc"] = radios[i].value;
	    	}
	    }
		var value = $("input[name=telPhone]").val();
		if(!testPhone(value)){
			navigator.notification.alert( 
	           	//inputs[i].placeholder.split(",")[0],  // 显示信息
	            "请正确填写您的联系方式", 
	            null,         // 警告被忽视的回调函数 
	            '提示',            // 标题 
	            '确定'                  // 按钮名称 
	        ); 
			return;
		}
		
		cordova.exec(
			function(){	
				//console.log("注册成功"); 
			}, 
			function(err) {
				//console.log("提交失败,请检查网络连接！");
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
		window.location.href="index.html?cube-action=pop";
	}
}

function fillData(data){
	console.log("fillData  -> "+data);
	if(data){
		$("#registInfo").html("您的设备已注册");
	}else{
		$("#registInfo").html("您的设备未进行注册");
	}
	$("input[name=deviceSrc]")[0].checked=true
	data = JSON.parse(data);

	var inputs = $("input");
	console.log("inputs -> "+ inputs.length);
	for(var i = 0; i < inputs.length; i++){
		var input = inputs[i];
		console.log(data[input.name]);
		if(data[input.name] && data[input.name] != null && input.type != "radio"){
			$(input).val(data[input.name]);
		}
	}
	var radios = $("input[name=deviceSrc]");
	console.log("radios -> "+ radios.length);
    for(var i = 0; i <radios.length; i++){
    	var radio = $(radios[i]);
    	if(radio.val() == data.deviceSrc){
    		console.log("匹配"+data.deviceSrc);
    		radios[i].checked = true;
    	}
    }
    console.log("fillData end");
}