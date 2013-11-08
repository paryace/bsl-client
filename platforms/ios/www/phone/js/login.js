new FastClick(document.body);
var myPsw = null;

window.addEventListener("keydown", function(evt) {
	if (evt.keyCode === 13) {
		$("#LoginBtn").trigger("click");
	}
});
$('input').focus(function() {
	var keyword = $(this).val();
	if (keyword == "" || keyword == undefined || keyword == null) {
		$(this).next(".del_content").hide();
	} else {
		$(this).next(".del_content").css("display", "inline");
	}

});
$('#username,#password').click(function(e) {
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
    }
};

$("#username_del").click(function() {
	$(this).parent().hide();
	$("#username").val("");
});
$("#password_del").click(function() {
	$(this).parent().hide();
	$("#password").val("");
});
$("#username,#password").live("input propertychange", function() {
	var keyword = $(this).val();
	if (keyword == "" || keyword == null || keyword == undefined) {
		$(this).next(".del_content").hide();
	} else {
		$(this).next(".del_content").css("display", "inline");
	}

});
$("body").click(function() {
	$(".del_content").hide();
});



$("#LoginBtn").click(function() {
	$(this).disabled = "disabled";
	var username = $("#username").val();
	
	var password = $("#realpsw").val();
                
	
	var isRemember = $('#isRemember:checked').val();

	if (isRemember === undefined) {
		isRemember = "false";
	}


	cordova.exec(function(data) {
		data = $.parseJSON(data);
		if (data.isSuccess === true) {
			$("#LoginBtn").removeAttr("disabled");
		}
	}, function(err) {

		err = $.parseJSON(err);
		$("#LoginBtn").removeAttr("disabled");
	}, "CubeLogin", "login", [username, password, isRemember]);

});

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


var app = {
	initialize: function() {
		this.bindEvents();
		loadLogin();
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
//			$("#password").val(data.password);
			
			if (data.isRemember === true) {
				$("#isRemember").attr("checked", 'checked');
				//myPsw = data.password;
			}
			myPsw = data.password;
            $("#realpsw").val(data.password);
            
			if(myPsw!== undefined &&myPsw!==null && myPsw!==""){
                $("#password").unbind("input");
				$("#password").val("asof0&4*");
                $("#password").bind("input",function(){
                      $("#password").val($(this).val());
                });
			}

		}, function(err) {
			alert(err);
		}, "CubeLogin", "getAccountMessage", []);
	}
};
app.initialize();