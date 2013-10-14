//
//  CubeApplication.h
//  Cube
//
//  Created by Justin Yip on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CubeModule.h"

@interface CubeApplication : NSObject{
    BOOL syncing;//是否正在同步
}

//属性
@property(nonatomic,copy)NSString *identifier;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *releaseNote;
@property(nonatomic,copy)NSString *iconUrl;
//app config url
@property(nonatomic,copy)NSString *url;

@property(nonatomic,copy)NSString *downloadUrl;

@property(nonatomic,copy)NSString *version;
@property(nonatomic,assign)NSInteger build;

@property(nonatomic,strong)NSMutableArray *modules;
@property(nonatomic,strong)NSMutableArray *updatableModules;
@property(nonatomic,strong)NSMutableArray *availableModules;
@property(nonatomic,strong)NSMutableArray *downloadingModules;


//@property(nonatomic,assign)BOOL isFirstRun;
@property(nonatomic,readonly)BOOL installed;

+(id)currentApplication;
+(NSMutableDictionary*)sortByCategroy:(NSMutableArray*)aArr;


-(void)sync;

-(CubeModule*)moduleForIdentifier:(NSString*)aIdentifier;
-(CubeModule*)availableModuleForIdentifier:(NSString*)aIdentifier;
-(CubeModule*)updatableModuleModuleForIdentifier:(NSString*)aIdentifier;
-(BOOL)judgeArray:(NSMutableArray*)tempArr ContainsModule:(CubeModule*)aModule;
//安装
-(void)install;


-(void)installJS;

-(void)installModule:(CubeModule*)aModule;
-(void)updateModule:(CubeModule*)aModule;

-(void)uninstallModule:(CubeModule*)aModule;
-(void)uninstallModule:(CubeModule*)aCubeModule didFinishBlock:(void (^)(void))callBack;
//需结合推送
-(void)startUpdateChecker;

-(NSMutableDictionary*)dictionary;

@end

extern NSString* const CubeSyncClickNotification;
extern NSString* const CubeSyncStartedNotification;
extern NSString* const CubeSyncFinishedNotification;
extern NSString* const CubeTokenTimeOutNotification;
extern NSString* const CubeSyncFailedNotification;

extern NSString* const CubeAppUpdateFinishNotification;
