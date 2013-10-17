//
//  NetworkConfig.h
//  pilot
//
//  Created by chen shaomou on 8/21/12.
//  Copyright (c) 2012 chen shaomou. All rights reserved.
//

#ifndef pilot_NetworkConfig_h
#define pilot_NetworkConfig_h

/////////////////////////********  生产  ********//////////////////////////////

//#define BASEURL @"http://icrew.csair.com/pilot"

//#define BASEURL @"http://172.16.49.10/pilot"
//#define BASEURL @"http://172.16.49.9/pilot"

//运行信息
//#define FLIGHT_SCHEDULE @"http://icrew.csair.com/mobile/flightScheduled_fast.action"

//软件更新地址
//#define UPDATESOFTWARE @"itms-services://?action=download-manifest&url=http://icrew.csair.com/jboss-root/resource/client/pilot.plist"


////////////////////////********  测试  ********////////////////////////////////

#define BASEURL @"http://10.108.68.134:8180/pilot"

//#define BASEURL @"http://192.168.1.116:8280/pilot"

//运行信息
#define FLIGHT_SCHEDULE @"http://10.108.68.134:8180/mobile/flightScheduled_fast.action"

//软件更新地址
#define UPDATESOFTWARE @"itms-services://?action=download-manifest&url=http://10.108.68.134:8180/jboss-root/resource/client/pilot.plist"

//////////////////////////////////////////////////////////////


#define LOGIN_URL @"/data/login"
#define NEWLOGIN_URL @"/data/newLogin"
#define USER_UPDATE_URL @"/data/user"
#define FEEDBACK_UPDATE_URL @"/data/feedback"
#define DEVICE_INFO @"/data/deviceInfo"
#define USER_QUERYALL_URL @"/data/users"
#define DEVICE_CHECK_REGISTER @"/data/deviceRegister/checkDeviceRegisted"
#define DEVICE_GETVERIFCODE @"/data/deviceRegister/getVerifCodeWithPhoneNo"
#define DEVICE_REGISTER @"/data/deviceRegister/register"
#define EbookList @"/data/ebooks"
#define Ebook_URL @"/download/ebook/"
#define FTPFile_URL @"/download/ftpFile"
#define Ebook_Chapter_URL @"/download/ebookChapter/"
#define VERSION_CHECK @"/data/versionCheck"
#define FLIGHT_TASK @"/data/flightTask"
#define FLIGHT_CABINORDER @"/data/cabinOrder"
#define PUSH_BIND_URL @"/data/bind/pushEntity"
#define PUSH_UNBIND_URL @"/data/unbind/pushEntity"
#define ARTICLE_INFO_URL @"/data/articleInfoList"
#define ARTICLE_LOG_INFO_URL @"/data/healthyDeclare"
#define HEALTHY_DECLARE_INFO_URL @"/data/onlineAnswer"
#define EXAM_LOG_INFO_URL @"/data/readyFinished"
#define TOWFILE_LIST @"/data/towFileNameList"
#define TOWFILE @"/download/towFile"
#define PLANFILE @"/download/flightPlanFile"
#define WEATHERMAP_LIST @"/data/weatherMapNameList"
#define TASK_SDES @"/data/flightTaskSDES"


//加密密钥
#define ENCRYPT_KEY					@"This is a secret keynews"

#define PDF_DOWNLOAD_START               @"start"
#define PDF_DOWNLOAD_PAUSE               @"pause"
#define PDF_DOWNLOAD_CANCEL              @"cancel"

//FTP远程文件路径
#define PHOTO_REMOTEPATH            @"/upload/can/photo"
#define FILE_REMOTEPATH             @"/ebupload/newsContent"
#define WEATHER_MAP_REMOTEPATH      @"/project/opweb/upload/t5"


#endif
