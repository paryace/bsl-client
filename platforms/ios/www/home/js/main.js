//解决点击延迟问题
new FastClick(document.body);
var packageName;
//封装cordova的执行方法，加上回调函数
var cordovaExec = function(plugin, action, parameters, callback) {
	cordova.exec(function(data) {
		if (callback !== undefined) {
			callback();
		}
	}, function(err) {
		//alert(err);
	}, plugin, action, parameters === null || parameters === undefined ? [] : parameters);
};

//首页接受到信息，刷新页面
var receiveMessage = function(identifier, count) {
	console.log("AAA进入index revceiveMessage count = " + count + identifier);
	var $moduleTips = $(".module_Tips[identifier='" + identifier + "']");
	console.log("size=" + $moduleTips.size());
	if (count > 0) {
		$moduleTips.html(count);
		$moduleTips.show();

	} else {
		$moduleTips.hide();
	}
};
var refreshMainPage = function() {
	loadModuleList("CubeModuleList", "mainList", "main", function() {
		window.mySwipe = Swipe(document.getElementById('slider'), {
			continuous: true,
			callback: function(index, elem) {
				console.log("index=" + index);
				var whichPage = index + 1;
				$("#position").children("li").removeClass("on");
				$("#position").children("li:nth-child(" + whichPage + ")").addClass("on");

			}
		});
	});
};
// 初始化界面
var isOver = 0;
var loadModuleList = function(plugin, action, type, callback) {
	if (isOver === 0) {
		isOver = isOver + 1;
		var i = 0;
		$("#swipe").html("");
		$("#position").html("");
		console.log('AAAAAA------------------ZHE');
		// cordova.exec(success,failed,plugin,action,[]);
		cordova.exec(function(data) {
			data = $.parseJSON(data);

			var valueArray = new Array;
			var keyArray = new Array;
			var s = 3;

			_.each(data, function(value, key) {
				if (key === "首页") {
					keyArray[0] = key;
					valueArray[0] = value;
				} else if (key === "次页") {
					keyArray[1] = key;
					valueArray[1] = value;
				} else if (key === "基础包") {
					keyArray[2] = key;
					valueArray[2] = value;
				} else {

					keyArray[s] = key;
					valueArray[s] = value;
					s++;
				}
				console.log(s);

			});
			console.log("keyArray0 " + keyArray[0]);
			console.log("keyArray1 " + keyArray[1]);
			console.log("valueArray0 " + valueArray[0]);
			console.log("valueArray1 " + valueArray[1]);
			console.log("AAAAAA-----1DATA");
			_.each(valueArray, function(value) {
				//alert(JSON.stringify(value));
				var len = value.length;
				var j = 0;

				//排列

				value = _.sortBy(value, function(v) {
					console.log("v.sortingWeight " + v.sortingWeight + "");
					console.log("v. " + v.stringify);
					return v.sortingWeight;

				});
				downloadFile(value.icon + "", packageName + "/moduleIcon", function(entry) {
					// document.body.innerHTML = "<img src  = " + entry.fullPath + ">";
					value.icon = entry.fullPath;
				});

				console.log("value2 = " + value.sortingWeight);

				_.each((value), function(value, key) {
					if (j % 12 === 0) {
						i++;
						$("#swipe").append("<div class='page_div'><ul id='myul" + i + "' clsss='scrollContent'></ul></div>");
						$("#position").append("<li></li>");
					}

					// var mark = value.icon;
					// if (mark.indexOf("?") > -1) {
					// 	mark = mark.substring(0, mark.indexOf("?"));
					// }
					// if (window.localStorage[mark] !== undefined) {
					// 	value.icon = window.localStorage[mark];
					// }
					console.log("aaaa --" + value.sortingWeight + "");
					$("#myul" + i).append(
						_.template($("#module_div_ul").html(), {
							'icon': value.icon,
							'name': value.name,
							'identifier': value.identifier,
							'moduleType': value.moduleType,
							'msgCount': value.msgCount
						}));
					j++;

				});

			});
			$("#position").children("li:nth-child(1)").addClass("on");
			console.log("i=" + i);
			if (callback !== undefined) {
				callback();
			}
			isOver = isOver - 1;
		}, function(err) {
			alert("获取页面出错");
		}, plugin, action, []);

	}
};

//设置按键
// $("#setting_btn").click(function() {
// 	cordovaExec("CubeModuleOperator", "setting");
// });
//搜索按键
$("#search_btn").click(function() {
	//搜索事件
	var keyword = $("#search_input").val();
	console.log("点击了搜索按键：keyword=" + keyword);


	if (keyword) {
		Toast("航班号或机未号!" + keyword, null);


		var myDate = new Date();


		var month = myDate.getMonth();

		var currentMonth = parseInt(month) + 1;
		var currentDay = myDate.getDate();

		var confirmTime = myDate.getFullYear() + "-" + (currentMonth < 10 ? "0" + currentMonth : currentMonth) + "-" + (currentDay < 10 ? "0" + currentDay : currentDay);

		console.log("confirmTime::++==" + confirmTime);


		var queryAction = {
			QueryType: '航班机尾号',
			querySite: 'flight',
			queryUrl: "",
			requestParams: {
				'fltDt': confirmTime,
				'fltNr': keyword
			},
			fromPage: "home"
		};
		console.log("点击了搜索按键：queryActiond=");


		window.localStorage['com.csair.dynamic-flightDynamic.html'] = JSON.stringify(queryAction);

		console.log(window.location.href);
		cordovaExec("CubeModuleOperator", "showModule", ["com.csair.dynamic", "main"]);
		//window.location = "../com.csair.dynamic/index.html#com.csair.dynamic/flightDynamic";

	} else {


		Toast("请输入航班号或机未号!", null);

	}

});


//机场天气模块点击

$("#weatherContent").click(function() {

	console.log("模块点击");
	var type = "main";
	var identifier = "com.csair.airport";
	console.log("module_click----" + identifier); /*var type = $(this).attr("moduleType");*/

	cordovaExec("CubeModuleOperator", "showModule", [identifier, type]);
});

//模块点击

$("li[identifier]").live("click", function() {

	console.log("模块点击");
	var type = "main";
	var identifier = $(this).attr("identifier");
	console.log("module_click----" + identifier); /*var type = $(this).attr("moduleType");*/

	var applicationCompetence = "111";
	var aircrewCompetence = "111";
	var crewmenCompetence = "111";

	//判断当前账号是否有权限进入此模块
	if (identifier === "com.csair.application") {

		if (applicationCompetence) {
			cordovaExec("CubeModuleOperator", "showModule", [identifier, type]);

		} else {

			Toast("对不起,您暂无权限进入此模块", null);

		}



	} else if (identifier === "com.csair.aircrew") {


		if (aircrewCompetence) {
			cordovaExec("CubeModuleOperator", "showModule", [identifier, type]);

		} else {

			Toast("对不起,您暂无权限进入此模块", null);

		}

	} else if (identifier === "com.csair.crewmen") {


		if (crewmenCompetence) {

			cordovaExec("CubeModuleOperator", "showModule", [identifier, type]);
		} else {

			Toast("对不起,您暂无权限进入此模块", null);

		}
	} else if (identifier === "com.csair.setting") {

		cordovaExec("CubeModuleOperator", "setting");
	} else {

		cordovaExec("CubeModuleOperator", "showModule", [identifier, type]);
	}


});
//没有权限的模块灰色显示

var unCompetence = function() {



};

// //登陆
// var socLogin = function() {

// 	getDate();

// 	$("#loader").attr({
// 		'style': 'display:block'
// 	});
// 	var username = window.localStorage["username"];
// 	var password = window.localStorage["password"];



// 	$.ajax({
// 		timeout: 2000 * 1000,
// 		url: "http://58.248.56.101/opws-mobile-web/j_spring_security_check",
// 		type: "get",
// 		data: {
// 			"username": username,
// 			"password": password
// 		},
// 		dataType: "json",
// 		success: function(data, textStatus, jqXHR) {
// 			console.log('列表数据加载成功：' + textStatus + " response:[" + data + "]");



// 			if (data.login === true) {


// 				window.localStorage["socUserInfo"] = JSON.stringify(data);
// 				getWeather();

// 			} else {



// 				Toast("登陆失败,请检查用户名和密码!", null);
// 			}

// 			closeLoader();
// 		},
// 		error: function(e, xhr, type) {


// 			console.error('列表数据加载失败：' + e + "/" + type + "/" + xhr);
// 			closeLoader();


// 			Toast("登陆失败,请检查网络连接!", null);
// 		}
// 	});


// };

//获取天气信息
var getWeather = function() {
	var me = this;
	//admin登陆后台接口传过来的基地为null，默认为广州
	var loginMessage = JSON.parse(window.localStorage["socUserInfo"]);

	var base = loginMessage.chnBase;
	console.log(base);
	//$("#base").html(base);

	$.ajax({
		timeout: 10 * 1000,
		url: "http://58.248.56.101/opws-mobile-web/mobile/flightinfo-FlightWeather-findWeather.action",
		type: "get",
		data: {
			"optArea": base
		},
		dataType: "json",
		success: function(data, textStatus, jqXHR) {
			console.log('列表数据加载成功：' + textStatus + " response:[" + data + "]");


			me.hasWeather = true;


			console.log("data=====================");
			console.log(data);

			console.log(data.weather.tempreture);
			console.log(data.weather.rmk);

			if (data.weather.rmk) {

				$("#weather").html(data.weather.rmk);

			}

			if (data.weather.tempreture) {

				$("#degree").html(data.weather.tempreture + "°");
			}

		},
		error: function(e, xhr, type) {


			console.error('列表数据加载失败：' + e + "/" + type + "/" + xhr);

			Toast("加载天气信息失败!", null);

		},

		complete: function(xhr, status) {

			// closeLoader();



		}
	});

};


// //登陆
// var socLogin = function() {


// 	var me = this;
// 	var username = window.localStorage["username"];
// 	var password = window.localStorage["password"];


// 	console.log(username + "=======================" + password);
// 	$.ajax({
// 		timeout: 2000 * 1000,
// 		url: "http://58.248.56.101/opws-mobile-web/j_spring_security_check",
// 		type: "get",
// 		data: {
// 			"username": username,
// 			"password": password,
// 			"loginFrom": "web"
// 		},
// 		dataType: "json",
// 		success: function(data, textStatus, jqXHR) {
// 			console.log('列表数据加载成功：' + textStatus + " response:[" + data + "]");
// 			console.log("登陆成功");
// 			console.log(data);

// 			if (data.login === true) {

// 				me.loginSuccess = true;
// 				window.localStorage["socUserInfo"] = JSON.stringify(data);


// 			}

// 		},
// 		error: function(e, xhr, type) {


// 			console.error('列表数据加载失败：' + e + "/" + type + "/" + xhr);

// 		}
// 	});


// };



var closeLoader = function() {



	$("#loader").attr({
		'style': 'display:none'
	});
};



this.hasWeather = false;
var me = this;



var timeWeather = setInterval(function() {

	console.log("获取天气信息开始");



	if (me.hasWeather) {

		console.log("获取天气信息成功");

		clearInterval(timeWeather);



	} else {

		// console.log("获取天气信息失败");

		// var loginMessage = JSON.parse(window.localStorage["socUserInfo"]);

		// if (loginMessage) {

		// 	console.log("基地信息存在====================");


		getWeather();

		// } else {
		// 	console.log("基地信息不存在====================");

		// 	socLogin();
		// }
	}
}, 10 * 1000);



//冒泡提示信息: msg:提示内容, duration:停留时间
var Toast = function(msg, duration) {
	duration = isNaN(duration) ? 3000 : duration;
	var m = document.createElement('div');
	m.innerHTML = msg;
	m.style.cssText = "width:60%; min-width:150px; background:#000; opacity:0.5; height:40px; color:#fff; line-height:40px; text-align:center; border-radius:5px; position:fixed; top:80%; left:20%; z-index:999999; font-weight:bold;";
	document.body.appendChild(m);
	setTimeout(function() {
		var d = 0.5;
		m.style.webkitTransition = '-webkit-transform ' + d + 's ease-in, opacity ' + d + 's ease-in';
		m.style.opacity = '0';
		setTimeout(function() {
			document.body.removeChild(m);
		}, d * 1000);
	}, duration);
};

var getDate = function() {

	//admin登陆后台接口传过来的基地为null，默认为广州
	var loginMessage = JSON.parse(window.localStorage["socUserInfo"]);

	var base = loginMessage.chnBase;
	console.log(base);
	$("#base").html(base);
	var weekday = new Array(7);
	weekday[1] = "星期一";
	weekday[2] = "星期二";
	weekday[3] = "星期三";
	weekday[4] = "星期四";
	weekday[5] = "星期五";
	weekday[6] = "星期六";
	weekday[0] = "星期日";
	var myDate = new Date();


	var month = myDate.getMonth();

	var currentMonth = parseInt(month) + 1;
	var currentDay = myDate.getDate();
	var day = weekday[myDate.getDay()];


	var date = currentMonth + "月" + currentDay + "日" + " " + day;
	$("#date").html(date);

};


//应用初始化
var app = {
	initialize: function() {
		this.bindEvents();

	},
	bindEvents: function() {
		console.info("2222");
		document.addEventListener('deviceready', this.onDeviceReady, false);

	},
	onDeviceReady: function() {
		console.info("22224444");

		app.receivedEvent('deviceready');
	},
	receivedEvent: function(id) {
		getDate();

		console.info("2222888");
		//loadModuleList("CubeModuleList", "mainList", "main");

		console.log("4");
		cordovaExec("CubeModuleOperator", "sync", [], function() {
			var osPlatform = device.platform;
			if (osPlatform.toLowerCase() == "android") {
				cordova.exec(function(data) {
					packageName = $.parseJSON(data).packageName;
					//如果是android，先获取到包名
					loadModuleList("CubeModuleList", "mainList", "main", function() {
						window.mySwipe = Swipe(document.getElementById('slider'), {
							continuous: true,
							callback: function(index, elem) {
								console.log("index=" + index);
								var whichPage = index + 1;
								$("#position").children("li").removeClass("on");
								$("#position").children("li:nth-child(" + whichPage + ")").addClass("on");

							}
						});


					});
				}, function(err) {
					console.log("获取Packagename失败");
				}, "CubePackageName", "getPackageName", []);
			} else {
				loadModuleList("CubeModuleList", "mainList", "main", function() {
					window.mySwipe = Swipe(document.getElementById('slider'), {
						continuous: true,
						callback: function(index, elem) {
							console.log("index=" + index);
							var whichPage = index + 1;
							$("#position").children("li").removeClass("on");
							$("#position").children("li:nth-child(" + whichPage + ")").addClass("on");

						}
					});


				});
			}



		});



	}
};
app.initialize();