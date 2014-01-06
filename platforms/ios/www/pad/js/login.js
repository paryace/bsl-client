var window_height = $(window).height();
window.addEventListener("keydown", function(evt) {
	if (evt.keyCode === 13) {
		$("#LoginBtn").trigger("click");
	}
});
$("body").click(function() {
	$(".del_content").hide();
	console.log("body click");
});
$('#username, #password').click(function(e) {
	if ($(this).val() !== null && $(this).val() !== "" && $(this).val !== undefined) {
		$(this).next(".del_content").css("display","inline");
	}

	e.preventDefault();
	e.stopPropagation();
});

var clearPsw = function(){

    var isRemember = $('#isRemember:checked').val();
	if (isRemember === undefined) {
		//alert("")
		isRemember = "false";
	}
    if(isRemember==="false"){
        $("#password").val("");
    }else{
    	$("#password").val("asof0&4*");
    	bindClearFakePwdEvent();
    }
};

$("#username_del").click(function() {
	$(this).hide();
	$("#username").val("");
});
$("#password_del").click(function() {
	$(this).hide();
	$("#password").val("");
});
$("#username,#password").live("input propertychange", function() {
	var keyword = $(this).val();
	if (keyword == "" || keyword == null || keyword == undefined) {
		$(this).next(".del_content").hide();
	} else {
		console.log("显示");
		$(this).next(".del_content").css("display", "inline");
	}

});

$("#LoginBtn").click(function() {
	$(this).disabled = "disabled";
	var username = $("#username").val();
	var password = $("#realpsw").val();

	var isRemember = $('#isRemember:checked').val();

	/*if (username === "" || username === null) {
		showAlert("账号不能为空", null, "提示", "确定");
		return;
	} else if (password === "" || password === null) {
		showAlert("密码不能为空", null, "提示", "确定");
		return;
	} else */
	if (isRemember === undefined) {
		//alert("")
		isRemember = "false";
	}
	// if(isRemember === 'false')
 //    {
 //        $("#realpsw").val("");
 //    }

	//是否启用离线登陆
	var isOffLine = $('#isOffLine:checked').val();
	if(isOffLine === undefined){
		isOffLine = "false";
	}

	cordova.exec(function(data) {
		console.log("ddddddddd"+data);
        if(data === 'false')
        {
            password="";
            $("#realpsw").val("");
            $("#password").val("");
            return;
        }
		data = $.parseJSON(data);
		if (data.isSuccess === true) {
			$("#LoginBtn").removeAttr("disabled");
		}
	}, function(err) {
		err = $.parseJSON(err);

		var tip = err.message;
        if(tip.indexOf("用户不存在") != -1)
        {
            $("#realpsw").val("");
            $("#password").val("");
            $("#username").val("");
                 
        }
        else if(tip.indexOf("帐号或密码错误") != -1)
        {
            $("#realpsw").val("");
            $("#password").val("");
            $("#username").val("");
                 
        }
        $("#LoginBtn").removeAttr("disabled");

		//showAlert(err.message, null, "提示", "确定");
	}, "CubeLogin", "login", [username, password, isRemember,isOffLine]);

});

/*var showAlert = function(message, callback, title, buttonName) {
	navigator.notification.alert(
		message, // message

	function() {
		if (callback !== null || callback !== undefined) {
			callback();
		}
	}, // callback
	title, // title
	buttonName // buttonName
	);
};*/

var loadLogin = function(){
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
}

function bindClearFakePwdEvent(){
	$("#password").bind("click",function(){
        $("#password").val("");
        $("#realpsw").val("");
        $("#password").unbind("click");
    })
}

var app = {
	initialize: function() {
		this.bindEvents();
		setTimeout(function(){
            loadLogin();
        },100);
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
			// $("#password").val(data.password);
			if (data.isRemember === true) {
				$("#isRemember").attr("checked", 'checked');
			}

			if (data.isOffLine === true) {
				$("#isOffLine").attr("checked", 'checked');
			}

			myPsw = data.password;
            $("#realpsw").val(data.password);
            
			if(myPsw!== undefined &&myPsw!==null && myPsw!==""){
                $("#password").unbind("input");
                //如果是显示加密码,则用户点击密码框时清空
                bindClearFakePwdEvent();
				$("#password").val("asof0&4*");
			}
            $("#password").bind("input",function(){
                $("#realpsw").val($(this).val());
            });

		}, function(err) {
			alert(err);
		}, "CubeLogin", "getAccountMessage", []);
	}
};
app.initialize();