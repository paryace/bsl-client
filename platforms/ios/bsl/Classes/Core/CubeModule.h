//
//  CubeModule.h
//  Cube
//
//  Created by Justin Yip on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMissingDependencyNeedInstallKey @"kMissingDependencyNeedInstallKey"
#define kMissingDependencyNeedUpgradeKey @"kMissingDependencyNeedUpgradeKey"


@interface CubeModule : NSObject

@property(nonatomic,assign)int showPushMsgCount;//显示消息条数

@property(nonatomic,assign)BOOL isAutoShow; //是否自动显示
@property(nonatomic,assign)int  showIntervalTime;//显示时间间隔
@property(nonatomic,strong)NSString *timeUnit;//时间的单位
@property(nonatomic,assign)BOOL isStop;
@property(nonatomic,assign)BOOL autoDownload;
@property(nonatomic,strong)NSString * discription;
@property(nonatomic,assign)int sortingWeight;//模块排序

@property(nonatomic,assign)BOOL busiDetail;
@property(nonatomic,strong)NSString *moduleBadge;


@property(nonatomic,strong)NSString *pushMsgLink;
@property(nonatomic,strong)NSString *identifier;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *releaseNote;
@property(nonatomic,strong)NSString *icon;

//online browse url
@property(nonatomic,strong)NSString *url;
//offline package download urls
@property(nonatomic,strong)NSString *bundle;
//wtf?
@property(nonatomic,strong)NSString *package;

@property(nonatomic,strong)NSString *version;
@property(nonatomic,assign)NSInteger build;
@property(nonatomic,strong)NSString *category;
@property (nonatomic,strong)NSString *local;

@property(nonatomic,strong)NSString *localImageUrl;

@property(nonatomic,strong)NSString *installType;

@property(nonatomic,assign)BOOL installed;

@property(nonatomic,assign)BOOL isDownloading;
@property(nonatomic,assign)float downloadProgress;
@property(nonatomic,strong)NSMutableArray *privileges;

@property(weak, nonatomic,readonly)NSString *iconUrl;

@property(nonatomic,assign)BOOL hidden;



//maybe download, maybe just add online module
-(void)install;
-(BOOL)uninstall;
-(void)update;
//download offline module


-(BOOL)moduleFileIsExit;

-(BOOL)moduleIsInstalled;

#pragma mark Serialization & Deserialization

//deserialize from json object to CubeModule object
+(CubeModule*)moduleFromJSONObject:(id)jsonObject;

-(NSURL*)runtimeURL;

//transfer this object to NSDictionary, for json serialization
-(NSMutableDictionary*)dictionary;

-(NSURL*)moduleDataDirectory;

-(NSString*)identifierWithBuild;

-(NSDictionary*)missingDependencies;

@end

extern NSString* const CubeModuleDownloadDidStartNotification;
extern NSString* const CubeModuleDownloadDidFinishNotification;
extern NSString* const CubeModuleDownloadDidFailNotification;

extern NSString* const CubeModuleInstallDidFinishNotification;
extern NSString* const CubeModuleInstallDidFailNotification;

extern NSString* const CubeModuleUpdateDidFinishNotification;
extern NSString* const CubeModuleUpdateDidFailNotification;
