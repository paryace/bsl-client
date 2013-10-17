define([], function() {
	var localRequest = false;
	var loginUrl = 'http://10.103.124.106:8088/opws-mobile-web/';
	var hostUrl = "http://10.103.124.106:8088/opws-mobile-web/mobile/";
	var urlEnding = "";


	if (localRequest) {
		hostUrl = "../com.csair.base/testData/";
		urlEnding = ".json";

	}

	var url = {
		"login": {
			"login": loginUrl + "j_spring_security_check" + urlEnding
		},
		"dynamic": {
			"findByFltNumOrTailNum": hostUrl + "flightinfo-FlightDynamic-findByFltNumOrTailNumJson.action" + urlEnding,
			"findByDepArvPage": hostUrl + "flightinfo-FlightDynamic-findByDepArvPageJson.action" + urlEnding,
			"findByAirPortImport": hostUrl + "flightinfo-FlightDynamic-findByAirPortImportJson.action" + urlEnding,
			"findByAirPort": hostUrl + "flightinfo-FlightDynamic-findByAirPortJson.action" + urlEnding,
			"findBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findBySoflSeqNum.action" + urlEnding,
			"findByFltTransfer": hostUrl + "flightinfo-FlightDynamic-findByFltTransferJson.action" + urlEnding,
			"findGateCarerInfoBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findGateCarerInfoBySoflSeqNum.action" + urlEnding,
			"findByFltWeightsInfoBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findByFltWeightsInfoBySoflSeqNumJson.action" + urlEnding,
			"findWaterInfoBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findWaterInfoBySoflSeqNum.action" + urlEnding,
			"findVipListBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findVipListBySoflSeqNum.action" + urlEnding,
			"findLoadSheetBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findLoadSheetBySoflSeqNum.action" + urlEnding,
			"findRouteAttributeBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findRouteAttributeBySoflSeqNum.action" + urlEnding,
			"findShareFltNumBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findShareFltNumBySoflSeqNum.action" + urlEnding,
			"findNewCapInfoBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findNewCapInfoBySoflSeqNum.action" + urlEnding,
			"findSelfInfoBySoflSeqNum": hostUrl + "flightinfo-FlightDynamic-findSelfInfoBySoflSeqNum.action" + urlEnding,
			"findRelease": hostUrl + "flightinfo-FlightRelease-findRelease.action" + urlEnding,
			"findWeather": hostUrl + "flightinfo-FlightRelease-findWeather.action" + urlEnding,
			"readDocuments": hostUrl + "flightinfo-FlightRelease-readDocuments.action" + urlEnding,
			"findSchRoute": hostUrl + "flightinfo-FlightDynamic-findSchRoute.action" + urlEnding,
			"findRadar2Route": hostUrl + "flightinfo-FlightDynamic-findRadar2Route.action" + urlEnding
		},
		"safe": {
			"saveEnsure": hostUrl + "flightinfo-FlightEnsure-saveEnsure.action" + urlEnding,
			"findEnsureById": hostUrl + "flightinfo-FlightEnsure-findEnsureById.action" + urlEnding,
			"findEnsureCustomize": hostUrl + "flightinfo-FlightEnsure-findEnsureCustomize.action" + urlEnding,
			"updateEnsureCustomize": hostUrl + "flightinfo-FlightEnsure-updateEnsureCustomize.action" + urlEnding,
			"findSubFltList": hostUrl + "flightinfo-FlightEnsure-findSubFltList.action" + urlEnding,
			"deleteEnsureSub": hostUrl + "flightinfo-FlightEnsure-deleteEnsureSub.action" + urlEnding,
			"findByAirPortJson": hostUrl + "flightinfo-FlightEnsure-findByAirPortJson.action" + urlEnding,
			"findByFltNumOrTailNumJson": hostUrl + "flightinfo-FlightEnsure-findByFltNumOrTailNumJson.action" + urlEnding,
			"insertEnsureSub": hostUrl + "flightinfo-FlightEnsure-insertEnsureSub.action" + urlEnding,
			"findRemarkHistoryList": hostUrl + "flightinfo-FlightEnsure-findRemarkHistoryList.action" + urlEnding,
			"insertRemarkHistory": hostUrl + "flightinfo-FlightEnsure-insertRemarkHistory.action" + urlEnding
		},
		"announcement": {
			"findFlightList": hostUrl + "flightinfo-FlightContacts-findFlightList.action" + urlEnding,
			"findFlightNotam": hostUrl + "flightinfo-FlightContacts-findFlightNotam.action" + urlEnding
		},
		"aircrew": {
			"findFltTaskList": hostUrl + "flightinfo-FlightCrewInfo-findFltTaskList.action" + urlEnding,
			"findCrewInfoList": hostUrl + "flightinfo-FlightCrewInfo-findCrewInfoList.action" + urlEnding,
			"findStaffList": hostUrl + "flightinfo-FlightCrewInfo-findStaffList.action" + urlEnding,
			"findSbyTaskList": hostUrl + "flightinfo-FlightCrewInfo-findSbyTaskList.action" + urlEnding,
			"findMealCar": hostUrl + "flightinfo-FlightCrewInfo-findMealCar.action" + urlEnding,
			"findSimTaskList": hostUrl + "flightinfo-FlightCrewInfo-findSimTaskList.action" + urlEnding,
			"findHistoryFly": hostUrl + "flightinfo-FlightCrewInfo-findHistoryFly.action" + urlEnding
		},
		"airport": {
			"findWeather": hostUrl + "flightinfo-FlightWeather-findWeather.action" + urlEnding,
			"findDelayByBase": hostUrl + "common-Common-findDelayByBase.action" + urlEnding,
			"getFltList": hostUrl + "flightinfo-FlihgtFocus-getFltList.action" + urlEnding,
			"getAirportFlightInfo": hostUrl + "airport-AirportInfo-getAirportFlightInfo.action" + urlEnding
		},
		"performance": {
			"getTowOrLdwResult": hostUrl + "flightinfo-FlightPerformance-getTowOrLdwResult.action" + urlEnding
		},
		"crewmen": {
			"findGrdTaskList": hostUrl + "flightinfo-FlightCrewInfo-findGrdTaskList.action" + urlEnding,
			"findFlyTask5Day": hostUrl + "flightinfo-FightAirborne-findFlyTask5Day.action" + urlEnding,
			"findOtherTaskList": hostUrl + "flightinfo-FlightCrewInfo-findOtherTaskList.action" + urlEnding,
			"findWeather": hostUrl + "flightinfo-FlightCrewInfo-findSbyTaskList.action" + urlEnding,
			"findPassportType": hostUrl + "flightinfo-FlightCrewInfo-findPassportType.action" + urlEnding
		},
		"todo": {
			"queryToDoListCount": hostUrl + "personal-ToDo-queryToDoListCount.action" + urlEnding,
			"findTodoEnsureList": hostUrl + "personal-ToDo-findTodoEnsureList.action" + urlEnding,
			"kkApplyConfirm": hostUrl + "personal-ToDo-kkApplyConfirm.action" + urlEnding,
			"findLeaderConfirmList": hostUrl + "personal-ToDo-findLeaderConfirmList.action" + urlEnding,
			"routePracticeConfirm": hostUrl + "personal-ToDo-routePracticeConfirm.action" + urlEnding,
			"queryFltApply": hostUrl + "personal-ToDo-queryFltApply.action" + urlEnding,
			"getUpdateLeader": hostUrl + "personal-ToDo-getUpdateLeader.action" + urlEnding,
			"leaderConfirmApproval": hostUrl + "personal-ToDo-leaderConfirmApproval.action" + urlEnding,
			"findLeaderConfirmLists": hostUrl + "personal-ToDo-findLeaderConfirmList.action" + urlEnding,
			"queryPractiseDetails": hostUrl + "personal-ToDo-queryPractiseDetails.action" + urlEnding,
			"sickApproval": hostUrl + "personal-ToDo-sickApproval.action" + urlEnding,
			"findSickApprovalList": hostUrl + "personal-ToDo-findSickApprovalList.action" + urlEnding,
			"queryToDoConfirmTask": hostUrl + "personal-ToDo-queryToDoConfirmTask.action" + urlEnding,
			"checkFltTask": hostUrl + "personal-ToDo-checkFltTask.action" + urlEnding,
			"findKkApplyList": hostUrl + "personal-ToDo-findKkApplyList.action" + urlEnding


		},
		"notification": {
			"findNoticeList": hostUrl + "flightinfo-FlightContacts-findNoticeList.action" + urlEnding,
			"getNewDelayList": hostUrl + "common-Common-getNewDelayList.action" + urlEnding,
			"findEbNotice": hostUrl + "flightinfo-FlightContacts-findEbNotice.action" + urlEnding,
			"findNoticeContent": hostUrl + "flightinfo-FlightContacts-findNoticeContent.action" + urlEnding,
			"findOtherNotice": hostUrl + "flightinfo-FlightContacts-findOtherNotice.action" + urlEnding
		},
		"personal": {
			"findNotStaffInfo": hostUrl + "flightinfo-FlightCrewInfo-findNotStaffInfo.action" + urlEnding,
			"findStaffInfo": hostUrl + "flightinfo-FlightCrewInfo-findStaffInfo.action" + urlEnding,
			"findStaffBaseInfo": hostUrl + "flightinfo-FlightCrewInfo-findStaffBaseInfo.action" + urlEnding,
			"updateStaffMobile": hostUrl + "flightinfo-FightAirborne-updateStaffMobile.action" + urlEnding,
			"updateStaffSign": hostUrl + "flightinfo-FightAirborne-updateStaffSign.action" + urlEnding
		},
		"suggestions": {
			"addIdeaResMessage": hostUrl + "flightinfo-FlightWeather-addIdeaResMessage.action" + urlEnding
		},
		"leading": {
			"findOnDutyLeader": hostUrl + "common-Common-findOnDutyLeader.action" + urlEnding
		},
		"application": {
			"findFlyApplyListByStaffNum": hostUrl + "flightinfo-FightAirborne-findFlyApplyListByStaffNum.action" + urlEnding,
			"findSickApplyList": hostUrl + "flightinfo-FightAirborne-findSickApplyList.action" + urlEnding,
			"insertFltApply": hostUrl + "flightinfo-FightAirborne-insertFltApply.action" + urlEnding,
			"updateComplain": hostUrl + "common-Common-updateComplain.action" + urlEnding,
			"findFlyApplyList": hostUrl + "flightinfo-FightAirborne-findFlyApplyList.action" + urlEnding
		},
		"overview": {
			"findFlyApplyListByStaffNum": hostUrl + "flightinfo-FightAirborne-findFlyApplyListByStaffNum.action" + urlEnding,
			"findSickApplyList": hostUrl + "flightinfo-FightAirborne-findSickApplyList.action" + urlEnding,
			"insertFltApply": hostUrl + "flightinfo-FightAirborne-insertFltApply.action" + urlEnding,
			"updateComplain": hostUrl + "common-Common-updateComplain.action" + urlEnding,
			"findFlyApplyList": hostUrl + "flightinfo-FightAirborne-findFlyApplyList.action" + urlEnding
		}
	};



	return url;
});