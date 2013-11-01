define(['zepto', 'underscore', 'cube/view','text!com.csair.deviceregist/register.html','cube/cube-dialog'], 
	function($, _, CubeView, Register){

	var isUpdate;
	var View = CubeView.extend({

		events: {
			"click #submitBtn":"submit" 
		},

		initialize: function(){

		},

		render: function(){
			$(this.el).html(Register);
			CubeView.prototype.render.call(this);
			return this;
		},

		onShow:function(){
			CubeView.prototype.onShow.call(this);
			this.queryAndFillDeviceInfo();
			if(isUpdate){
				$("#cancel").show();
			}
		},

		queryAndFillDeviceInfo:function(){
			if(cordova && cordova.exec){
				cordova.exec(
					function(data){
						if(data){
							var inputs = this.el.querySelector("input");
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
						me.error();
		        	}
		        , "DeviceRegister", "queryDevcieInfo", []);
			}
		},

		submit:function(){
			var me = this;
			if(cordova &&cordova.exec){
				var submitType = "submitInfo";//默认新增
				if(isUpdate){
					submitType = "updateDevice";
				}
				var inputs = this.el.querySelector("input");
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
						me.success();
					}, 
					function(err) {
						me.error();
		        	}
		        , "DeviceRegister", submitType, [json]);
			}
		},
		error:function(){
			new Dialog({
					autoshow: true,
					title: '提示',
					content: "提交失败,请检查网络连接！"
				}, {
					configs: [{
						title: '确定',
						eventName: 'ok'
					}],
					ok: function() {}
			}); 
		},
		success:function(){
			new Dialog({
					autoshow: true,
					title: '提示',
					content: "注册成功"
				}, {
					configs: [{
						title: '确定',
						eventName: 'ok'
					}],
					ok: function() {
						cordova.exec(function(){}, function(err) {alert(err);}
		        		, "DeviceRegister", "", []);
					}
			}); 
		}

	});

	return View;
});

