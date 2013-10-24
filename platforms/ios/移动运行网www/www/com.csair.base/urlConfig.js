define(['zepto'], function($) {

	var host = {
		localRequest: false,
		loginUrl: 'http://58.248.56.101/opws-mobile-web/',
		hostUrl: "http://58.248.56.101/opws-mobile-web/mobile/",
		urlEnding: ""
		//test ip http://10.103.124.104:8080/opws-mobile-web   
		//out:58.248.56.101  in:172.16.116.6  
		//dashen:10.108.19.180:8080  wangruiqing:10.108.19.38:8080
	};

	window.sessionStorage['naviAnimate'] = JSON.stringify(false);
	// var localRequest = true;
	// var loginUrl = 'http://10.103.124.106:8088/opws-mobile-web/';
	// var hostUrl = "http://10.103.124.106:8088/opws-mobile-web/mobile/";
	// var urlEnding = "";


	if (host.localRequest) {
		host.hostUrl = "../com.csair.base/testData/";
		host.urlEnding = ".json";

	}

	return {
		//TODO
		ajax: function() {
			//Todo
			console.log(arguments);

			// arguments[0].timeout = 20 * 1000;
			var error = arguments[0].error;
			var argumentsRelogin = arguments[0];
			arguments[0].error = function(we, wxhr, wtype) {
				console.log('--------error--------')
				console.log(arguments);
				if ($(we.response).find('div.errorPanel').length > 0) {
					error.call(we, wxhr, wtype);
					return;
				}
				var username = window.localStorage['username'];
				var password = window.localStorage['password'];
				$.ajax({
					timeout: 2000 * 1000,
					url: host.loginUrl + "j_spring_security_check",
					type: "post",
					data: {
						'username': username,
						'password': password,
						'loginFrom': 'web'
					},
					dataType: "json",
					success: function(res, textStatus, jqXHR) {
						if (res.login === true) {
							window.localStorage['socUserInfo'] = JSON.stringify(res);
							$.ajax(argumentsRelogin);
						} else {

						}


						console.info(res);
					},
					error: function(e, xhr, type) {
						error.call(e, xhr, type);
					}
				});
			}


			// var complete = arguments[0].complete;
			// arguments[0].complete = function(){
			// 	console.log('complete');
			// 	console.log(arguments);
			// }

			$.ajax(arguments[0]);
		},

		"login": {
			"login": host.loginUrl + "j_spring_security_check",
			"logout": host.loginUrl + "j_spring_security_logout"
		},
		"dynamic": {
			"findByFltNumOrTailNum": host.hostUrl + "flightinfo-FlightDynamic-findByFltNumOrTailNumJson.action" + host.urlEnding,
			"findByDepArvPage": host.hostUrl + "flightinfo-FlightDynamic-findByDepArvPageJson.action" + host.urlEnding,
			"findByAirPortImport": host.hostUrl + "flightinfo-FlightDynamic-findByAirPortImportJson.action" + host.urlEnding,
			"findByAirPort": host.hostUrl + "flightinfo-FlightDynamic-findByAirPortJson.action" + host.urlEnding,
			"findBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findBySoflSeqNum.action" + host.urlEnding,
			"findByFltTransfer": host.hostUrl + "flightinfo-FlightDynamic-findByFltTransferJson.action" + host.urlEnding,
			"findGateCarerInfoBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findGateCarerInfoBySoflSeqNum.action" + host.urlEnding,
			"findByFltWeightsInfoBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findByFltWeightsInfoBySoflSeqNumJson.action" + host.urlEnding,
			"findWaterInfoBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findWaterInfoBySoflSeqNum.action" + host.urlEnding,
			"findVipListBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findVipListBySoflSeqNum.action" + host.urlEnding,
			"findLoadSheetBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findLoadSheetBySoflSeqNum.action" + host.urlEnding,
			"findRouteAttributeBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findRouteAttributeBySoflSeqNum.action" + host.urlEnding,
			"findShareFltNumBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findShareFltNumBySoflSeqNum.action" + host.urlEnding,
			"findNewCapInfoBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findNewCapInfoBySoflSeqNum.action" + host.urlEnding,
			"findSelfInfoBySoflSeqNum": host.hostUrl + "flightinfo-FlightDynamic-findSelfInfoBySoflSeqNum.action" + host.urlEnding,
			"findRelease": host.hostUrl + "flightinfo-FlightRelease-findRelease.action" + host.urlEnding,
			"findWeather": host.hostUrl + "flightinfo-FlightRelease-findWeather.action" + host.urlEnding,
			"readDocuments": host.hostUrl + "flightinfo-FlightRelease-readDocuments.action" + host.urlEnding,
			"findSchRoute": host.hostUrl + "flightinfo-FlightDynamic-findSchRoute.action" + host.urlEnding,
			"findRadar2Route": host.hostUrl + "flightinfo-FlightDynamic-findRadar2Route.action" + host.urlEnding,
			"flightSubscribe": host.hostUrl + "flightinfo-FlightDynamic-flightSubscribe.action" + host.urlEnding,
			"delFlightSubscribe": host.hostUrl + "flightinfo-FlightDynamic-delFlightSubscribe.action" + host.urlEnding,
			"findWeatherByDepArcCd": host.hostUrl + "flightinfo-FlightDynamic-findWeatherByDepArcCd.action" + host.urlEnding,
			"findBySoflSeqNumOtherInfo": host.hostUrl + "flightinfo-FlightDynamic-findBySoflSeqNumOtherInfo.action" + host.urlEnding
		},
		"safe": {
			"saveEnsure": host.hostUrl + "flightinfo-FlightEnsure-saveEnsure.action" + host.urlEnding,
			"findEnsureById": host.hostUrl + "flightinfo-FlightEnsure-findEnsureById.action" + host.urlEnding,
			"findEnsureCustomize": host.hostUrl + "flightinfo-FlightEnsure-findEnsureCustomize.action" + host.urlEnding,
			"updateEnsureCustomize": host.hostUrl + "flightinfo-FlightEnsure-updateEnsureCustomize.action" + host.urlEnding,
			"findSubFltList": host.hostUrl + "flightinfo-FlightEnsure-findSubFltList.action" + host.urlEnding,
			"deleteEnsureSub": host.hostUrl + "flightinfo-FlightEnsure-deleteEnsureSub.action" + host.urlEnding,
			"findByAirPortJson": host.hostUrl + "flightinfo-FlightEnsure-findByAirPortJson.action" + host.urlEnding,
			"findByFltNumOrTailNumJson": host.hostUrl + "flightinfo-FlightEnsure-findByFltNumOrTailNumJson.action" + host.urlEnding,
			"insertEnsureSub": host.hostUrl + "flightinfo-FlightEnsure-insertEnsureSub.action" + host.urlEnding,
			"findRemarkHistoryList": host.hostUrl + "flightinfo-FlightEnsure-findRemarkHistoryList.action" + host.urlEnding,
			"insertRemarkHistory": host.hostUrl + "flightinfo-FlightEnsure-insertRemarkHistory.action" + host.urlEnding
		},
		"announcement": {
			"findFlightList": host.hostUrl + "flightinfo-FlightContacts-findFlightList.action" + host.urlEnding,
			"findFlightNotam": host.hostUrl + "flightinfo-FlightContacts-findFlightNotam.action" + host.urlEnding
		},
		"aircrew": {
			"findFltTaskList": host.hostUrl + "flightinfo-FlightCrewInfo-findFltTaskList.action" + host.urlEnding,
			"findCrewInfoList": host.hostUrl + "flightinfo-FlightCrewInfo-findCrewInfoList.action" + host.urlEnding,
			"findStaffList": host.hostUrl + "flightinfo-FlightCrewInfo-findStaffList.action" + host.urlEnding,
			"findSbyTaskList": host.hostUrl + "flightinfo-FlightCrewInfo-findSbyTaskList.action" + host.urlEnding,
			"findMealCar": host.hostUrl + "flightinfo-FlightCrewInfo-findMealCar.action" + host.urlEnding,
			"findSimTaskList": host.hostUrl + "flightinfo-FlightCrewInfo-findSimTaskList.action" + host.urlEnding,
			"findHistoryFly": host.hostUrl + "flightinfo-FlightCrewInfo-findHistoryFly.action" + host.urlEnding,
			"findHistoryFlyByTime": host.hostUrl + "flightinfo-FlightCrewInfo-findHistoryFlyByTime.action" + host.urlEnding
		},
		"airport": {
			"findWeather": host.hostUrl + "flightinfo-FlightWeather-findWeather.action" + host.urlEnding,
			"findWeatherList": host.hostUrl + "flightinfo-FlightWeather-findWeatherList.action" + host.urlEnding,
			"findDelayByBase": host.hostUrl + "common-Common-findDelayByBase.action" + host.urlEnding,
			"getFltList": host.hostUrl + "flightinfo-FlihgtFocus-getFltList.action" + host.urlEnding,
			"getAirportFlightInfo": host.hostUrl + "airport-AirportInfo-getAirportFlightInfo.action" + host.urlEnding
		},
		"performance": {
			"getTowOrLdwResult": host.hostUrl + "flightinfo-FlightPerformance-getTowOrLdwResult.action" + host.urlEnding,
			"downloadFile": host.hostUrl + "flightinfo-FlightPerformance-downloadFile.action" + host.urlEnding
		},
		"crewmen": {
			"findGrdTaskList": host.hostUrl + "flightinfo-FlightCrewInfo-findGrdTaskList.action" + host.urlEnding,
			"findFlyTask5Day": host.hostUrl + "flightinfo-FightAirborne-findFlyTask5Day.action" + host.urlEnding,
			"findOtherTaskList": host.hostUrl + "flightinfo-FlightCrewInfo-findOtherTaskList.action" + host.urlEnding,
			"findWeather": host.hostUrl + "flightinfo-FlightCrewInfo-findSbyTaskList.action" + host.urlEnding,
			"findPassportType": host.hostUrl + "flightinfo-FlightCrewInfo-findPassportType.action" + host.urlEnding
		},
		"todo": {
			"queryToDoListCount": host.hostUrl + "personal-ToDo-queryToDoListCount.action" + host.urlEnding,
			"findTodoEnsureList": host.hostUrl + "personal-ToDo-findTodoEnsureList.action" + host.urlEnding,
			"kkApplyConfirm": host.hostUrl + "personal-ToDo-kkApplyConfirm.action" + host.urlEnding,
			"findLeaderConfirmList": host.hostUrl + "personal-ToDo-findLeaderConfirmList.action" + host.urlEnding,
			"routePracticeConfirm": host.hostUrl + "personal-ToDo-routePracticeConfirm.action" + host.urlEnding,
			"queryFltApply": host.hostUrl + "personal-ToDo-queryFltApply.action" + host.urlEnding,
			"getUpdateLeader": host.hostUrl + "personal-ToDo-getUpdateLeader.action" + host.urlEnding,
			"leaderConfirmApproval": host.hostUrl + "personal-ToDo-leaderConfirmApproval.action" + host.urlEnding,
			"findLeaderConfirmLists": host.hostUrl + "personal-ToDo-findLeaderConfirmList.action" + host.urlEnding,
			"queryPractiseDetails": host.hostUrl + "personal-ToDo-queryPractiseDetails.action" + host.urlEnding,
			"sickApproval": host.hostUrl + "personal-ToDo-sickApproval.action" + host.urlEnding,
			"findSickApprovalList": host.hostUrl + "personal-ToDo-findSickApprovalList.action" + host.urlEnding,
			"queryToDoConfirmTask": host.hostUrl + "personal-ToDo-queryToDoConfirmTask.action" + host.urlEnding,
			"checkFltTask": host.hostUrl + "personal-ToDo-checkFltTask.action" + host.urlEnding,
			"findKkApplyList": host.hostUrl + "personal-ToDo-findKkApplyList.action" + host.urlEnding


		},
		"notification": {
			"findNoticeList": host.hostUrl + "flightinfo-FlightContacts-findNoticeList.action" + host.urlEnding,
			"getNewDelayList": host.hostUrl + "common-Common-getNewDelayList.action" + host.urlEnding,
			"findEbNotice": host.hostUrl + "flightinfo-FlightContacts-findEbNotice.action" + host.urlEnding,
			"findNoticeContent": host.hostUrl + "flightinfo-FlightContacts-findNoticeContent.action" + host.urlEnding,
			"findOtherNotice": host.hostUrl + "flightinfo-FlightContacts-findOtherNotice.action" + host.urlEnding
		},
		"personal": {
			"findNotStaffInfo": host.hostUrl + "flightinfo-FlightCrewInfo-findNotStaffInfo.action" + host.urlEnding,
			"findStaffInfo": host.hostUrl + "flightinfo-FlightCrewInfo-findStaffInfo.action" + host.urlEnding,
			"findStaffBaseInfo": host.hostUrl + "flightinfo-FlightCrewInfo-findStaffBaseInfo.action" + host.urlEnding,
			"updateStaffMobile": host.hostUrl + "flightinfo-FightAirborne-updateStaffMobile.action" + host.urlEnding,
			"updateStaffSign": host.hostUrl + "flightinfo-FightAirborne-updateStaffSign.action" + host.urlEnding
		},
		"suggestions": {
			"addIdeaResMessage": host.hostUrl + "flightinfo-FlightWeather-addIdeaResMessage.action" + host.urlEnding
		},
		"leading": {
			"findOnDutyLeader": host.hostUrl + "common-Common-findOnDutyLeader.action" + host.urlEnding
		},
		"application": {
			"findFlyApplyListByStaffNum": host.hostUrl + "flightinfo-FightAirborne-findFlyApplyListByStaffNum.action" + host.urlEnding,
			"findSickApplyList": host.hostUrl + "flightinfo-FightAirborne-findSickApplyList.action" + host.urlEnding,
			"insertFltApply": host.hostUrl + "flightinfo-FightAirborne-insertFltApply.action" + host.urlEnding,
			"updateComplain": host.hostUrl + "common-Common-updateComplain.action" + host.urlEnding,
			"deleteFltApply": host.hostUrl + "flightinfo-FightAirborne-deleteFltApply.action" + host.urlEnding,
			"findFlyApplyList": host.hostUrl + "flightinfo-FightAirborne-findFlyApplyList.action" + host.urlEnding
		},
		"overview": {
			"getRunInfo": host.hostUrl + "airport-AirportInfo-getRunInfo.action" + host.urlEnding
		}
	};

});