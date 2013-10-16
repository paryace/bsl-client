new FastClick(document.body);

$("#login_btn").click(function() {
	console.log("点击了登录按键11111111111111111111111111");
	$(".user_content").addClass("wait");
	$(".remember_content").addClass("wait");
	$(".login_btn_content").addClass("wait");
	$(".loginBlock").addClass("wait");
	$(".login_text").addClass("wait");
	$(".logo").addClass("wait");

	var username = $("#username").val();
	var password = $("#password").val();

	window.localStorage["username"] = username;
	window.localStorage["password"] = password;



	var isRemember = $('#isRemember:checked').val();
	if (isRemember === undefined) {
		isRemember = "false";
	}
	socLogin(username, password, isRemember);


});

// setInterval(function(){

$("#isRemember").focus();
var bodyHeight = $(window).height();
$("body").css({
	'height': bodyHeight + 'px'
	// ,
	// 'min-height': bodyHeight + 'px'
});

$("html").css({
	'height': bodyHeight + 'px'
	// ,
	// 'min-height': bodyHeight + 'px'
});

// },300);



//变色龙平台登陆

var bslLogin = function(username, password, isRemember) {

console.log("变色龙平台登陆开始");
	cordova.exec(function(data) {
		console.log("进入exec");
		data = $.parseJSON(data);
		if (data.isSuccess === true) {



		}
	}, function(err) {}, "CubeLogin", "login", [username, password, isRemember]);

};



//移动运行网登陆
var socLogin = function(username, password, isRemember) {

console.log("移动运行网登陆开始");

	// var username = window.localStorage["username"];
	// var password = window.localStorage["password"];


	console.log(username + "=======================" + password);
	$.ajax({
		timeout: 2000 * 1000,
		url: "http://58.248.56.101/opws-mobile-web/j_spring_security_check",
		type: "get",
		data: {
			"username": username,
			"password": password,
			"loginFrom": "web"
		},
		dataType: "json",
		success: function(data, textStatus, jqXHR) {
			console.log('列表数据加载成功：' + textStatus + " response:[" + data + "]");
			console.log("登陆成功");
			console.log(data);

			if (data.login === true) {


				window.localStorage["socUserInfo"] = JSON.stringify(data);

				bslLogin(username, password, isRemember);

				


			}

			setTimeout(function(){
					$(".user_content").removeClass("wait");
					$(".remember_content").removeClass("wait");
					$(".login_btn_content").removeClass("wait");
					$(".loginBlock").removeClass("wait");
					$(".login_text").removeClass("wait");
					$(".logo").removeClass("wait");
				},500);

		},
		error: function(e, xhr, type) {
			$(".user_content").removeClass("wait");
			$(".remember_content").removeClass("wait");
			$(".login_btn_content").removeClass("wait");
			$(".loginBlock").removeClass("wait");
			$(".login_text").removeClass("wait");
			$(".logo").removeClass("wait");

			alert("登录失败")

			console.error('列表数据加载失败：' + e + "/" + type + "/" + xhr);

		}
	});


};



var app = {
	initialize: function() {
		this.bindEvents();
	},
	bindEvents: function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	onDeviceReady: function() {
		app.receivedEvent('deviceready');
	},
	receivedEvent: function(id) {
		cordova.exec(function(data) {
			data = $.parseJSON(data);
			$("#username").val(data.username);
			$("#password").val(data.password);
			if (data.isRemember === true) {
				$("#isRemember").attr("checked", 'checked');
			}
		}, function(err) {
			alert(err);
		}, "CubeLogin", "getAccountMessage", []);
	}
};
app.initialize();