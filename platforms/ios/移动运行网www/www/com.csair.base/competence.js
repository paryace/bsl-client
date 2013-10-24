define([], function() {



	var data = {};

	var device = {};
	var aircrew = {};
	var crewmen = {};
	var application = {};
	var todo = {};
	var dynamic = {};
	var personal = {};

	var yes = "Y";
	var no = "N";



	device.deviceId = 'a779cabef809b22a88e4dd683fa758ac';

	//判断是否存在

	var isEmpty = function(src) {
		var socUserInfoStr = window.localStorage["socUserInfo"];
		if(socUserInfoStr == "null" || socUserInfoStr == null){
			return false;
		}

		var socUserInfo = JSON.parse(socUserInfoStr);

		//console.info(socUserInfo);

		//权限列表
		var authList = socUserInfo.authList;

		//console.info(authList);


		for (var i = 0; i < authList.length; i++) {
			if (authList[i] == src) {
				return true;
			}
		}
		return false;



	};



	//判断是是空勤人员还是非空勤人员,,非空勤



	if (isEmpty("persion2_information")) {
		//空勤人员个人待办  个人信息

		todo.competence = yes; //个人待办 Y为空勤人员 N为非空勤人员
		personal.competence = yes; //个人信息  Y为空勤人员个人信息页面  N为非空勤人员个人信息页面
		application.competence = yes; //乘务申请  Y为可以进入此模块
		crewmen.competence = yes; //空勤任务  Y为可以进入此模块

		aircrew.competence = no; //空勤人员不可以进入 机组任务模块



	} else {

		todo.competence = no;
		application.competence = no;
		personal.competence = no;
		crewmen.competence = no;



		//判断是否有进入机组任务的权限 Y为可以N为不可以


		if (isEmpty("soc101") || isEmpty("soc102")) {

			aircrew.competence = yes;

		} else {

			aircrew.competence = no;
		}



		//判断非空勤人员有哪些待办任务  Y为有  N为没有


		//航线实习权限
		if (isEmpty("soc153") || isEmpty("soc154") || isEmpty("soc155") ||
			isEmpty("soc157")) {

			todo.routesInternship = yes;

		} else {

			todo.routesInternship = no;
		}



		//病假流程权限
		if (isEmpty("soc149") || isEmpty("soc198") || isEmpty("soc125") || isEmpty(
			"soc196") || isEmpty("soc174") || isEmpty("soc197")) {

			todo.sickLeave = yes;

		} else {

			todo.sickLeave = no;
		}


		//航班申请权限
		if (isEmpty("soc187") || isEmpty("soc188")) {

			todo.flightsApplication = yes;

		} else {

			todo.flightsApplication = no;
		}

		//位子随机权限
		if (isEmpty("soc182") || isEmpty("kkPri1") || isEmpty("kkPri2")) {

			todo.setRandom = yes;

		} else {

			todo.setRandom = no;
		}

		//领导确认权限 soc105||soc106||soc202
		if (isEmpty("soc105") || isEmpty("soc106") || isEmpty("soc202")) {

			todo.leadersshipRecognized = yes;

		} else {

			todo.leadersshipRecognized = no;
		}



	}


	//航班动态机组成员权限 vip查看权限 保障信息录入权限
	//机组成员 查看权限

	if (isEmpty("soc101") || isEmpty("soc102") || isEmpty("soc160")) {

		dynamic.aircrew = yes;

	} else {

		dynamic.aircrew = no;
	}


	//vip查看权限   soc108||soc109
	if (isEmpty("soc108") || isEmpty("soc109")) {

		dynamic.vip = yes;

	} else {

		dynamic.vip = no;
	}
	//保障录入 录入权限  soc199||soc200

	if (isEmpty("soc199") || isEmpty("soc200")) {

		dynamic.safe = yes;

	} else {

		dynamic.safe = no;
	}

	data.device = device;
	data.aircrew = aircrew;
	data.crewmen = crewmen;
	data.application = application;
	data.todo = todo;
	data.dynamic = dynamic;
	data.personal = personal;

	return data;
});