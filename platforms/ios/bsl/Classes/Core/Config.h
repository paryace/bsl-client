//
//  Config.h
//  Cube-iOS
//
//  Created by Justin Yip on 2/2/13.
//
//


#ifndef Cube_iOS_Config_h
#define Cube_iOS_Config_h

//服务器地址 
extern NSString* const kServerURLString;

//登陆地址
extern NSString* const kServerLoginURLString;


//应用的app key
extern NSString* const kAPPKey;

//xmpp host
extern NSString* const kXMPPHost;

// 即时通读api
extern NSString* const kAPIServerAPI;

//xmpp domain
extern NSString* const kXMPPDomin;

//注册设备
extern NSString* const kPushServerRegisterUrl;

//发送回执
extern NSString* const kPushServerReceiptsUrl;

//应用程序名字 可能没用了
extern NSString* const kAPPName;

//xmpp port
extern int kXMPPPort;

//图片上传地址
extern NSString* const kFileUploadUrl;

//二期获取消息地址
extern NSString* const kPushGetMessageUrl;

//群聊地址
extern NSString* const kMUCSevericeDomin;

//更新签到
extern NSString* const kUpdatePushTagsUrl;

#endif
