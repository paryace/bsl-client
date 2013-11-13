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
var receiveMessage = function(identifier, count, display) {
	console.log("AAA进入index revceiveMessage count = " + count + identifier + display);
	var $moduleTips = $(".module_Tips[moduletype='main'][identifier='" + identifier + "']");
	console.log("size=" + $moduleTips.size());
	if (display) {
		if (count > 0) {
			$moduleTips.html(count);
			$moduleTips.show();

		} else {
			$moduleTips.html(count);
			$moduleTips.hide();
		}

	} else {
		$moduleTips.hide();
	}
	if (myScroll) {
		myScroll.refresh();
		myScroll.scrollTo(0, 1, 200, true);
	}

};
//自动更新查新界面
var refreshMainPage = function(identifier, type, moduleMessage) {

	console.log("refreshMainPage refreshMainPage refreshMainPage refreshMainPage");
	console.log("进入refreshMainPage" + type + "..." + identifier);
	if ($('#top_left_btn').hasClass('back_bt_class')) {

	} else {

		//主页面
		console.log("进入main页面");

		/*addModule(identifier, "main", moduleMessage);
		$("li[identifier='" + identifier + "']").css('opacity', '0.5');*/
		if (isOver === 0) {
			isOver = isOver + 1;
			console.log("刷新。。。。");
			loadModuleList("CubeModuleList", "mainList", "main", function() {
				//gridLayout();
				if (myScroll) {
					myScroll.refresh();
				}
				isOver = isOver - 1;
			});
		}



	}

};



//进度获取
var updateProgress = function(identifier, count) {
	console.log('进入updateProgress');
	if (count == -1) {
		$(".module_div ul li .module_li_img .progress[identifier='" + identifier + "']").css('display', 'block');
	} else if (count >= 0 && count <= 100) {

		console.log("count>=0 && count <=100");
		if ($(".module_div ul li .module_li_img .progress[identifier='" + identifier + "']").css('display') == "none") {
			console.log("updateProgress隐藏，显示");
			$(".module_div ul li .module_li_img .progress[identifier='" + identifier + "']").css('display', 'block');
		}
		$(".module_div ul li .module_li_img .progress[identifier='" + identifier + "'] .bar").css('width', count + "%");

		var $crud_btn_2 = $(".module_li .curd_btn[identifier='" + identifier + "']");
		$crud_btn_2.attr("disabled", "disabled");
		console.log("adafasdfasfadsfasdfsfsdfsfasfasfsdfsdaf");
		var btn_title_2 = $crud_btn_2.html();
		console.log("adfasfasdfasdfdadsfs " + btn_title_2);
		if (btn_title_2 == "安装") {
			$crud_btn_2.html("正在安装");
		} else if (btn_title_2 == "删除") {
			$crud_btn_2.html("正在删除");
		} else if (btn_title_2 == "更新") {
			$crud_btn_2.html("正在更新");
		}



	} else if (count == 101) {
		$(".module_div ul li .module_li_img .progress[identifier='" + identifier + "']").css('display', 'none');


		var $crud_btn = $(".module_li .curd_btn[identifier='" + identifier + "']");
		var btn_title = $crud_btn.html();
		if (btn_title == "正在安装") {
			$crud_btn.html("安装");
		} else if (btn_title == "正在删除") {
			$crud_btn.html("删除");
		} else if (btn_title == "正在更新") {
			console.log("title正在更新10101010101");
			$crud_btn.html("更新");
		}
		$crud_btn.removeAttr("disabled");

	}

};

//模块增删，刷新模块列表(uninstall，install，upgrade)
var refreshModule = function(identifier, type, moduleMessage) {

	if ($('#top_left_btn').hasClass('back_bt_class')) {
		console.log("进入refreshModule " + type + "..." + identifier);

		if (type === "uninstall") {
			console.log("进入uninstall");
			//已安装减一个
			console.log("已安装页面减一个");
			$(".module_li[moduletype='install'][identifier='" + identifier + "']").remove();
			//未安装加一个
			//addModule(identifier, "uninstall", moduleMessage);
			console.log("未安装的加一个成功");
			//更新有则减
			$(".module_li[moduletype='upgrade'][identifier='" + identifier + "']").remove();
		} else if (type === "install") {
			console.log("进入install");
			//未安装减一个
			$(".module_li[moduletype='uninstall'][identifier='" + identifier + "']").remove();
			$(".module_li[moduletype='upgrade'][identifier='" + identifier + "']").remove();
			//已安装加一个
			//addModule(identifier, "install", moduleMessage);
			//更新不变
		} else if (type === "upgrade") {
			//已安装替换
			//addModule(identifier, "install", moduleMessage);
			//更新减一个
			$(".module_li[moduletype='upgrade'][identifier='" + identifier + "']").remove();
			//未安装不变
		} else if (type === "main") {
			//addModule(identifier, "main", moduleMessage);
		}


	} else {
		//主页面
		console.log("主界面、、");
		$("li[identifier='" + identifier + "']").css('opacity', '1');
		//判断模块 hidden
		var isHidden = $("li[identifier='" + identifier + "']").attr("hidden");
		console.log("是否显示？？？？" + isHidden);
		if (isHidden == "true") {
			$("li[identifier='" + identifier + "']").remove();
		}
	}
	checkModules();


};
var addModule = function(identifier, type, moduleMessage) {
	var mm = $.parseJSON(moduleMessage);
	//如果该模块不存在，则生成
	if ($(".scrollContent_li[modules_title='" + mm.category + "']").size() < 1) {
		var tag = $(".scrollContent_li").size();
		//获取模板名
		var moduleContentTemplate = $("#t2").html();

		var moduleContentHtml = _.template(moduleContentTemplate, {
			'muduleTitle': mm.category,
			"tag": tag
		});
		$(".mainContent").find(".scrollContent").append(moduleContentHtml);
	}

	//如果存在，先删除，再添加
	if ($("li[identifier='" + identifier + "']").size() > 0) {
		$("li[identifier='" + identifier + "']").remove();
	}

	var moduleItemTemplate = $("#module_div_ul").html();

	/*downloadFile(mm.icon, packageName + "/moduleIcon", function(entry) {
		mm.icon = entry.fullPath;
	});*/

	mm.releaseNote = subStrByCnLen(mm.releaseNote + "", 21);

	var moduleItemHtml = _.template(moduleItemTemplate, {
		'icon': mm.icon,
		'name': mm.name,
		'moduleType': type,
		'identifier': mm.identifier,
		'version': mm.version,
		'releasenote': mm.releaseNote,
		'btn_title': changeBtnTitle(type),
		"updatable": mm.updatable,
		"local": mm.local,
		"msgCount": mm.msgCount,
		"hidden": mm.hidden
	});
	$(".scrollContent_li[modules_title='" + mm.category + "']").children('div').children('ul').append(moduleItemHtml);
	if (myScroll) {
		myScroll.refresh();
	}


};
//检查模块信息的完整性，如果没有模块，则隐藏
var checkModules = function() {
	console.log('AAAAAA----检查模块信息的完整性，如果没有模块，则隐藏');
	$.each($(".scrollContent_li"), function(index, data) {

		if ($(this).children('.module_div').children('.module_div_ul').children('.module_li').size() < 1) {
			$(this).remove();

		} else {
			var show_module_lis = $(this).children('.module_div').children('.module_div_ul').children('.module_li');
			$.each($(show_module_lis), function(i, show_module_li) {
				if ($(show_module_li).css('display') == "none") {
					console.log("有隐藏的对象");
					$(show_module_li).parent('.module_div_ul').parent('.module_div').parent('.scrollContent_li').remove();

				}
			});

		}

	});

};

var changeBtnTitle = function(type) {
	switch (type) {
		case "install":
			return "删除";
			break;
		case "uninstall":
			return "安装";
			break;
		case "upgradable":
			return "更新";
			break;
		case "upgrade":
			return "更新";
			break;
		case "main":
			return "删除";
			break;

	}
};
/*$(document).ready(function() {*/
// 选中模块操作菜单，传入需要激活的按钮名称（uninstall，install，upgrade）
var activeModuleManageBarItem = function(type) {
	// 移除所有选中
	$(".buttomContent .buttom_btn_group .btn").removeClass("active");
	// 选中当前点击
	$(".buttomContent .buttom_btn_group .btn[data='" + type + "']").addClass("active");
};

//点击模块的时候触发事件
var module_all_click = function() {
	/*$("li[identifier] .module_li_img , li[identifier] .module_push, li[identifier] .detail").bind('click', function() {*/
	$("li[identifier]").bind('click', function() {



		console.log("模块父类点击");
		/*var type = $(this).parent(".module_li").attr("moduleType");*/
		var type = $(this).attr("moduleType");
		/*var identifier = $(this).parent(".module_li").attr("identifier");*/
		var identifier = $(this).attr("identifier");
		console.log("AAAAAmodule_all_click----" + type + " == " + identifier);
		//隐藏数量消息
		//var $moduleTips = $(".module_Tips[moduletype='main'][identifier='" + identifier + "']");
		//$moduleTips.hide();
		cordovaExec("CubeModuleOperator", "showModule", [identifier, type]);

	});
};

//点击curd按钮事件
var curd_btn_click = function() {
	console.log("操作按钮点击");

	$(".module_li .curd_btn").bind('click', function(e) {
		e.preventDefault();
		e.stopPropagation();
		var that = this;
		$(this).attr("disabled", "disabled");
		var btn_title = $(this).html();


		var showMessage = "确定" + btn_title + "该模块";
		navigator.notification.confirm(
			showMessage, // message

			function(buttonIndex) {

				if (buttonIndex === 1) {
					//alert("buttonIndex " + buttonIndex);
					$(that).removeAttr("disabled");
					return;
				} else if (buttonIndex === 2) {
					//	alert("buttonIndex " + buttonIndex);
					if (btn_title == "安装") {
						$(that).html("正在安装");
					} else if (btn_title == "删除") {
						$(that).html("正在删除");
					} else if (btn_title == "更新") {
						$(that).html("正在更新");
					}

					var type = $(that).attr("moduleType");
					console.log("202 type=" + type);
					var identifier = $(that).attr("identifier");

					var action = "";
					//alert("action "+action);
					if (type == "install") {
						action = "uninstall";
					} else if (type == "uninstall") {
						action = "install";
					} else if (type == "upgrade") {
						action = "upgrade";
					}
					//开始安装、删除
					cordovaExec("CubeModuleOperator", action, [identifier], function() {
						console.log("操作Callback");
						checkModules();
						$(that).removeAttr("disabled");
						console.log("更新完成更改title " + action);
						$(that).html(btn_title);
					});


				}
			}, // callback to invoke with index of button pressed
			'提示信息', // title
			'取消,确定' // buttonLabels
		);



		/*	if (btn_title == "安装") {
			$(this).html("正在安装");
		} else if (btn_title == "删除") {
			$(this).html("正在删除");
		} else if (btn_title == "更新") {
			$(this).html("正在更新");
		}



		var type = $(this).attr("moduleType");
		console.log("202 type=" + type);
		var identifier = $(this).attr("identifier");

		var action = "";
		if (type == "install") {
			action = "uninstall";
		} else if (type == "uninstall") {
			action = "install";
		} else if (type == "upgradable") {
			action = "upgrade";
		}
		//开始安装、删除
		cordovaExec("CubeModuleOperator", action, [identifier], function() {
			console.log("操作Callback");
			checkModules();
			$(this).removeAttr("disabled");
			console.log("更新完成更改title");
			$(this).html(btn_title);
		});*/



	});
};


var changeLayout = function(oldfilename, newfilename, type) {
	//replacejscssfile("css/gridview.css", "css/listview.css", "css");
	replacejscssfile(oldfilename, newfilename, type);
}


// 初始化界面
var initial = function(type, data) {
	console.log("AAAAAAAA initial=" + type);
	var i = 0;



	/*<!--     
    //把data转换成array
	var array = [];
	for(var category in data){
		array.push({"key":category,"value":data[category]});
	}
	array.sort(function(c1,c2){
        //        排序最前面           最后面
        if(c1.key == "公共功能" || c2.key == "基本功能"){
            return -1;
        }
        if(c1.key == "基本功能" || c2.key == "公共功能"){
            return 1;
        }
        return 0;
     })
    
	_.each(array, function(obj) {

        var key = obj.key;
        var data = obj.value;
		$("#myul").append(_.template($("#t2").html(), {
			'muduleTitle': key,
			'tag': i
		}));
		_.each((data), function(value, key) {
     -->*/
	//<!--
	_.each(data, function(value, key) {

		$("#myul").append(_.template($("#t2").html(), {
			'muduleTitle': key,
			'tag': i
		}));
		_.each((value), function(value, key) {

			//-->


			console.log('AAAAAAAA identifier icon = ' + value.identifier + " -- " + value.icon);

			//处理，只有在首页的时候才显示有统计数据
			/*if (type !== "main") {
				value.msgCount = 0;
			}*/
			//更新的图标，如果在未安装里面，不应该出现
			if (type === 'uninstall') {
				value.updatable = false;
			}

			// downloadFile(value.icon, packageName + "/moduleIcon", function(entry) {
			// 	value.icon = entry.fullPath;
			// 	console.log("缓存后的图片地址：" + value.icon);
			// });
			value.name = subStrByCnLen(value.name + "", 9);
			value.releaseNote = subStrByCnLen(value.releaseNote + "", 21);
			//console.log("value.releasenote=" + value.releaseNote);
			$('.module_div_ul[num="' + i + '"]').append(
				_.template($("#module_div_ul").html(), {
					'icon': value.icon,
					'name': value.name,
					'moduleType': type,
					'identifier': value.identifier,
					'version': value.version,
					'releasenote': value.releaseNote,
					'btn_title': changeBtnTitle(type),
					"updatable": value.updatable,
					"local": value.local,
					"msgCount": value.msgCount,
					"hidden": value.hidden
				}));
		});
		i = i + 1;
	});
	i = 0;
};



// 加载列表，渲染成html
var isOver = 0;
var loadModuleList = function(plugin, action, type, callback) {
	//if (isOver === 0) {
	//	isOver = isOver + 1;
	var accountName = "";
	//获取用户名
	cordova.exec(function(account) {
		console.log("进入exec获取accountName");
		var a = $.parseJSON(account);
		accountName = a.accountname;
		$('.account_content').html("<h4>欢迎" + accountName + "登录</h4>");
		//$(".mainContent").html("");
		//$(".mainContent").remove();


	}, function(err) {
		accountName = "";
	}, "CubeAccount", "getAccount", []);
	if (accountName !== "") {
		accountName = " " + accountName + " ";
	}

	$(".mainContent").html("");
	$(".mainContent").remove();

	var mainContent = $('<div class="mainContent"><ul id="myul" class="scrollContent nav nav-list"></ul>');
	$("#scroller").append(mainContent);
	$(".mainContent").css('padding-bottom', '50px');
	console.log('AAAAAA------------------ZHE');
	// cordova.exec(success,failed,plugin,action,[]);
	cordova.exec(function(data) {
		data = $.parseJSON(data);
		initial(type, data);
		//绑定点击事件
		//$("li[identifier]").die('click');
		module_all_click();
		curd_btn_click();
		if (myScroll) {
			myScroll.refresh();
		}

		checkModules();
		//isOver = isOver - 1;
		//如果回调方法不为空，则执行该回调方法
		if (callback !== undefined) {
			callback();
		}
	}, function(err) {
		isOver = isOver - 1;
	}, plugin, action, []);

	//}



};
var backToMain = function(){
	$(".back_btn").trigger("click");
}

// 左边按键--设置、返回
$('#top_left_btn')
	.bind("click",
		function() {
			$('#top_left_btn').addClass("disabled");
			isOver = 0;
			if ($(this).hasClass('back_bt_class')) {
				// 返回按键

				$('#top_left_btn').removeClass('back_bt_class');
				$('#top_left_btn').removeClass("back_btn");
				$('#top_left_btn').addClass("left_btn");
				//alert("shanchu le back_bt_class");
				$('.buttomContent').css('display', 'none');


				$('#title').html("南航移动应用");
				$('#manager_btn').show();
				//$('#top_left_btn').addClass("btn").css("background","url('img/settingbutton.ing') no-repeat").css("width","24px").css("height","24px");

				//$('#top_left_btn').addClass("left_btn").addClass("btn");
				
				

				//开启欢迎光临
				$('.account_content').show();
				$('.searchContent').css("height", "60px");

				//返回刷新列表
				//$('#top_left_btn').removeClass("disabled");
				loadModuleList("CubeModuleList", "mainList", "main", function() {
					gridLayout();
					if (myScroll) {
						myScroll.refresh();
						$('#top_left_btn').removeClass("disabled");
					}
				});


			} else {

				// 设置按键
				$('#top_left_btn').removeClass("disabled");
				cordovaExec("CubeModuleOperator", "setting");



			}


		});


// 检测屏幕是否伸缩
var LastHeight = window.screen.availHeight;
$(window).resize(function() {
	//$(".mainContent").height($(window).height() - 50);
	var availHeight = $(window).height();
	console.log("LastHeight " + LastHeight);
	console.log("availHeight " + availHeight);
	if (Math.abs(LastHeight - availHeight) > 100) {
		if ((LastHeight - availHeight) > 0) {
			//键盘弹出
			console.log("键盘弹出了");
			$('.buttomContent').hide();
		} else {
			console.log("键盘隐藏了。。。");
			//键盘隐藏
			if ($('#top_left_btn').hasClass('back_bt_class')) {
				$('.buttomContent').show();
			}
		}
	}
	LastHeight = availHeight;
	if (myScroll) {
		myScroll.refresh();
	}
});
/*$("#searchInput").click(function(e) {
	e.preventDefault();
	e.stopPropagation();
	if ($('#top_left_btn').hasClass('back_bt_class')) {
		var osPlatform = device.platform;
		if(osPlatform.toLowerCase() == "android"){
			$('.buttomContent').hide();
		}
		
	}
});*/
/*$("body").click(function() {
	console.log("body click");
	if ($('#top_left_btn').hasClass('back_bt_class')) {
		$('.buttomContent').show();
	}

});*/
$("#wrapper").live("touchend", function() {
	console.log("body touchend");
	if (myScroll) {
		myScroll.refresh();
	}

});
$(".del_content").click(function() {
	console.log("点击了");
	$("#searchInput").val("");
	$(".del_content").hide();

	var scrollContent_lis = $('#myul').children('li');
	$.each(scrollContent_lis, function(index, li) {
		var module_lis = $(li).children('div').children('ul').children('li');
		$.each(module_lis, function(index, module_li) {
			$(module_li).show();
		});

		scrollContent_lis.show();
		// end
	});



});
// 搜索框事件
$("#searchInput").live("input propertychange", function() {
	var me = $(this);
	var keyword = me.val();
	if (keyword == "" || keyword == undefined || keyword == null) {
		$(".del_content").hide();
	} else {
		$(".del_content").css("display", "inline");
	}
	console.log("keyword=" + keyword);
	var scrollContent_lis = $('#myul').children('li');
	$.each(scrollContent_lis, function(index, li) {
		var module_lis = $(li).children('div').children('ul').children('li');
		var i = 0;
		$.each(module_lis, function(index, module_li) {

			var titlename = $(module_li).children('div:nth-child(3)').children('div:nth-child(1)').html();
			if (keyword !== "") {
				console.log(keyword.length + "keyword 之前" + keyword);
				keyword = trim(keyword);
				console.log(keyword.length + "keyword 之后" + keyword);
				if (titlename.toLowerCase().indexOf(keyword.toLowerCase()) < 0) {
					$(module_li).hide();
				} else {
					$(module_li).show();
					i++;
				}
			} else {
				$(module_li).show();
			}
		});
		if (i > 0) {
			$(li).show();
		} else {
			$(li).hide();
		}

		i = 0;
		if (keyword == "") {
			scrollContent_lis.show();
		}
		// end
	});

	//myScroll.refresh();
	setTimeout(function() {
		if (myScroll) {
			myScroll.refresh();
		}
	}, 100);
});

var listLayout = function() {

	console.log("listview");
	changeLayout("css/gridview.css", "css/listview.css", "css");
	$("li[identifier]").die("touchstart");
	$("li[identifier]").die("touchend");

	$("li[identifier]").live("touchstart", function() {
		$(this).css("background", "-webkit-gradient(linear, 10% 100%, 10% 100%, from(#d7d7d7), to(#c8c8c8))");
	});


	$("li[identifier]:nth-of-type(odd)").live("touchend", function() {

		$(this).css("background", "#ffffff");

	});
	$("li[identifier]:nth-of-type(even)").live("touchend", function() {
		if ($('#listview_btn').hasClass("active")) {
			$(this).css("background", "#f5f5f5");
		} else {
			console.log("not avtive #fffffff");
			$(this).css("background", "#ffffff");
		}
	});
	$(".module_li .curd_btn").live("touchstart", function() {
		if ($('#listview_btn').hasClass("active")) {
			$(this).css("background", "-webkit-gradient(linear, 0% 0%, 0% 100%, from(#767878), to(#A8A5A3)) !important");
			$("li[identifier]:nth-of-type(odd)").css("background", "#ffffff");
			$("li[identifier]:nth-of-type(even)").css("background", "#f5f5f5");
		}
	});

	$(".module_li .curd_btn").live("touchend", function() {
		if ($('#listview_btn').hasClass("active")) {
			$(this).css("background", "-webkit-gradient(linear, 0% 80%, 0% 0%, from(#efefef), to(#dddddd)) !important");
			$("li[identifier]:nth-of-type(odd)").css("background", "#ffffff");
			$("li[identifier]:nth-of-type(even)").css("background", "#f5f5f5");
		}
	});

	$("li[identifier]:nth-of-type(even)").css("background", "#f5f5f5");

	//清楚查找栏数据
	//$("#searchInput").val("");
	if ($('#top_left_btn').hasClass('back_bt_class')) {
		//管理界面
		//alert("进入管理界面");
		//隐藏 > 图标
		$('.module_div ul li .icon-chevron-right').css('display', 'none');
		//显示 curd_btn
		$('.module_div ul li .curd_btn').css('display', 'inline');


		//禁止本地模块curd_btn显示
		$.each($('.module_div ul .module_li .curd_btn'), function(index, item) {
			if ($(item).attr('local') === null || $(this).attr('local') === undefined || $(item).attr('local') == "") {
				$(this).show();
			} else {
				$(this).hide();
			}

		});
	} else {
		//查看界面
		//alert("进入查看界面");
		//设置 > 图标显示
		$('.module_div ul li .icon-chevron-right').css('display', 'inline');
		//隐藏version显示
		$('.detail .module_li_version').css('display', 'none');
		//隐藏releasenote显示
		$('.detail .module_li_releasenote').css('display', 'none');
		//设置titlename位置
		$('.detail .module_li_titlename').css('top', '15px').css('font-size', '1.2em');


	}
	//切换active
	$('#listview_btn').addClass('active');
	$('#gridview_btn').removeClass('active');

	setTimeout(function() {
		if (myScroll) {
			myScroll.refresh();
			myScroll.scrollTo(0, 0, 200, false);
		}

	}, 100);
};

var gridLayout = function() {
	console.log("gridview");
	$("li[identifier]").die("touchstart");
	$("li[identifier]").die("touchend");
	$("li[identifier]").live("touchstart", function() {
		$(this).css("background", "-webkit-gradient(linear, 10% 100%, 10% 100%, from(#d7d7d7), to(#c8c8c8))");
		//$("li[identifier]").die("touchstart");

	});
	$("li[identifier]").live("touchend", function() {
		$(this).css("background", "#f5f5f5)");
		//$("li[identifier]").live("touchstart", function());
	});
	$(".module_li .curd_btn").die("touchstart");

	$(".module_li .curd_btn").die("touchend");



	changeLayout("css/listview.css", "css/gridview.css", "css");

	$("li[identifier]").css("background", "#ffffff");
	//清楚查找栏数据
	//$("#searchInput").val("");
	//隐藏 > 标记图
	$('.module_div ul li .icon-chevron-right').css('display', 'none');
	//隐藏curd_btn
	$('.module_div ul li .curd_btn').css('display', 'none');
	//设置titlename位置
	$('.detail .module_li_titlename').css('font-size', '1em').css("top", "5px");
	//切换active
	$('#gridview_btn').addClass('active');
	$('#listview_btn').removeClass('active');

	setTimeout(function() {
		if (myScroll) {
			myScroll.refresh();
			myScroll.scrollTo(0, 0, 200, false);
		}

	}, 100);
}

$('#listview_btn').bind('click', function() {
	if (!$('#listview_btn').hasClass("active")) {
		listLayout();
		setTimeout(function() {
			if (myScroll) {
				myScroll.refresh();
			}
		}, 100);
	}

});

$('#gridview_btn').bind('click', function() {
	if (!$('#gridview_btn').hasClass("active")) {
		gridLayout();
		setTimeout(function() {
			if (myScroll) {
				myScroll.refresh();
			}
		}, 100);
	}

});

// 管理按钮
$('#manager_btn')
	.click(function() {
		console.log("点击管理按键");

		$('#manager_btn').addClass("disabled");
		console.log("点击");
		cordovaExec("CubeModuleOperator", "sync", ["manager"], function() {
			console.log("开始同步");
			$('#manager_btn').removeClass("disabled");
			loadModuleList("CubeModuleList", "uninstallList", "uninstall", function() {
				console.log("222");
				isOver = 0;
				$("#searchInput").val("");
				$('#manager_btn').hide();
				//完成后设置listview
				$('.buttomContent').css('display', 'block');
				$('#title').html("模块管理");


				//关闭欢迎光临
				$('.account_content').hide();
				$('.searchContent').css("height", "37px");
				$('#top_left_btn').removeClass('left_btn');
				$('#top_left_btn').addClass('back_btn');
				//设置左边按键class做标志

				//$('#top_left_btn').removeClass("btn").css("background","url('img/nav_back@2x.ing') no-repeat").css("height","32px").css("width","48px");
				$('#top_left_btn').removeClass("left_btn");
				$('#top_left_btn').addClass("back_btn");
				//$('#top_left_btn').removeClass("left_btn").removeClass("btn");
				

				$('#top_left_btn').addClass('back_bt_class');
				// 处理模块管理问题
				var type = "uninstall";
				activeModuleManageBarItem(type);
				listLayout();
				cordovaExec("CubeModuleOperator", "manager");
				if (myScroll) {
					myScroll.refresh();
					console.log("同步后刷新界面");
				}

			});

			console.log("同步完成");
			//myScroll.refresh();
		});
		$('#manager_btn').removeClass("disabled");
	});


//处理底下按钮
$(".buttomContent .buttom_btn_group .btn").click(function() {
	var type = $(this).attr("data");
	console.log("butom type=" + type);
	$("#searchInput").val("");
	//active设置
	//alert("buttom_btn点击了" + type);

	if (!$(this).hasClass("active")) {
		activeModuleManageBarItem(type);
		var t = type;
		if (type == "upgrade") {
			type = "upgradable";
		}

		loadModuleList("CubeModuleList", type + "List", t, function() {
			if ($('#listview_btn').hasClass('active')) {
				listLayout();

			}

			if (myScroll) {
				myScroll.refresh();
			}

		});

	}

});


//---------------------------------------------------------------------------------------------


//应用初始化
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


		//loadModuleList("CubeModuleList", "mainList", "main");
		cordovaExec("CubeModuleOperator", "sync", [], function() {
			//alert(result);
			var osPlatform = device.platform;
			if (osPlatform.toLowerCase() == "android") {
				cordova.exec(function(data) {
					packageName = $.parseJSON(data).packageName;
					//如果是android，先获取到包名
					loadModuleList("CubeModuleList", "mainList", "main", function() {
						if (myScroll) {
							myScroll.refresh();
						}
					});
				}, function(err) {
					console.log("获取Packagename失败");
				}, "CubePackageName", "getPackageName", []);
			} else {
				loadModuleList("CubeModuleList", "mainList", "main", function() {
					if (myScroll) {
						myScroll.refresh();
					}
				});
			}



		});
		// loadModuleList("CubeModuleList", "mainList", "main");
		// cordovaExec("CubeModuleOperator", "sync", [], function() {
		// 	//alert(result);
		// 	loadModuleList("CubeModuleList", "mainList", "main", function() {
		// 		myScroll.refresh();
		// 	});
		// });
	}
};
app.initialize();