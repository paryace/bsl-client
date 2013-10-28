/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  cube-ios
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//


#import "AppDelegate.h"

#import "LoginViewController.h"
#import "CustomNavigationBar.h"
#import "BaseNavViewController.h"
#import "HTTPRequest.h"
#import "ConfigManager.h"
#import "HTTPRequest.h"
#import "UIDevice+IdentifierAddition.h"

#import <Cordova/CDVPlugin.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MessageRecord.h"
#import "NSData+Hex.h"
#import "SVProgressHUD.h"
#import "NSFileManager+Extra.h"
#import "UpdateChecker.h"


#import "Login_IpadViewController.h"
#import "MainViewViewController.h"
#import "Login_IphoneViewController.h"
#import "Main_IphoneViewController.h"
#import "PushGetMessageInfo.h"

#import "OperateLog.h"
#import "IMServerAPI.h"
#import "ChatLogic.h"
#import "JSONKit.h"
//#ifndef _DEBUG

//#define _DEBUG

//#endif

void uncaughtExceptionHandler(NSException*exception){
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);

}

@interface AppDelegate ()<UIApplicationDelegate,XMPPIMActorDelegate,UIAlertViewDelegate>
@property (assign,nonatomic) CFURLRef soundFileURLRef;
@property (assign,nonatomic) SystemSoundID soundFileObject;

-(void)postOpreateLog;
-(void)updateCollectionFriends;
@end
@implementation AppDelegate

@synthesize window;
@synthesize navControl;
@synthesize uc;
@synthesize xmpp;
@synthesize moduleReceiveMsg;

- (id)init{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
    int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
    NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    self = [super init];
    
    return self;
}

#pragma mark UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions{
    
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    if (launchOptions){
        //现在每一次开app 都运行接收推送，暂不要这段代码了
        
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil){
            [[PushGetMessageInfo sharedInstance] updatePushMessage];
        }
        
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;


    
    UpdateChecker *__uc = [[UpdateChecker alloc] initWithDelegate:nil];
    self.uc=__uc;
    __uc=nil;
    [self.uc check];
    
    [self registerForRemoteNotification];
    [self referencePushSound];
    
//    [self registerDevice];
    //项目发现未见有使用该代码
//    self.downQueueActor = [[DownQueueActor alloc]init];
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    
    if(!cubeApp.installed){
        [cubeApp install];
    }else{
        [cubeApp installJS];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didLogin) name:@"LoginSuccess" object:nil];

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    
    
    self.window.autoresizesSubviews = YES;
    
    //end------
    //异步加载push actor
   // [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
//    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad){
        BaseNavViewController* nav=[[BaseNavViewController alloc] init];
        [nav setNavigationBarHidden:YES];
        self.navControl=nav;
        self.window.rootViewController=nav;
        nav=nil;
//    }
    
    [self showLoginView:YES];
    [self.window makeKeyAndVisible];
    
    //开启定时任务将记录发送给服务端begin
    
    //[NSTimer timerWithTimeInterval:10.0f target:self selector:@selector(postOpreateLog) userInfo:nil repeats:NO];

    [self performSelector:@selector(postOpreateLog) withObject:nil afterDelay:30.0f];
    
    
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"applicationDidBecomeActive");

}

-(void)showLoginView:(BOOL)newLogin{

    [self.navControl popToRootViewControllerAnimated:NO];

    //清楚浏览器缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]){
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
  
    [xmpp teardownStream];
//    [xmpp disConnect];
//    if(!newLogin)return;
    if([navControl.viewControllers count]<1){
        if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone){
            Login_IphoneViewController* controller=[[Login_IphoneViewController alloc] init];
           // self.window.rootViewController=controller;
              [self.navControl pushViewController:controller animated:NO];
            controller=nil;
        }else{
            Login_IpadViewController* controller = [[Login_IpadViewController alloc]initWithNibName:@"Login_IpadViewController" bundle:nil];
//            self.window.rootViewController=controller;

            
            [self.navControl pushViewController:controller animated:NO];
            controller=nil;
        }
    }
    

}


-(void)showExit{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"账号已在别处登录" delegate:self cancelButtonTitle:@"重新登录" otherButtonTitles:nil, nil];
    alertView.tag = 100;
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 0) {

        [self showLoginView:NO];
    }
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.xmpp.managedObjectContext save:nil];
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    
#if TARGET_IPHONE_SIMULATOR
    
	NSLog(@"The iPhone simulator does not process background network traffic.Inbound traffic is queued until the keepAliveTimeout:handler: fires");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			
			// Do other keep alive stuff here.
		}];
	}
}

-(void)applicationWillEnterForeground:(UIApplication *)application{
    
    
    if ([self.window.rootViewController class] == [LoginViewController class]) {
        [self.uc check];
    }
    
    [[PushGetMessageInfo sharedInstance] updatePushMessage];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    
    /*
    if([navControl.visibleViewController isKindOfClass:[LoginViewController class]]){
        [self.uc check];

    }
     */
}


/*
-(void)registerDevice{
    
    __block FormDataRequest *request = [FormDataRequest requestWithURL:[NSURL URLWithString:kDeviceRegisterUrl]];
    
    [request setPostValue:kAPPName forKey:@"appIdentifier"];
    
    [request setPostValue:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    [request setPostValue:[[UIDevice currentDevice] name] forKey:@"deviceName"];
    
    [request setPostValue:[[UIDevice currentDevice] model] forKey:@"os"];
    
    [request setPostValue:[[UIDevice currentDevice] systemVersion] forKey:@"osVersion"];
    
    [request setRequestMethod:@"POST"];
    
    [request startAsynchronous];
    
}
 */

//加入apns推送功能
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{

    [[PushGetMessageInfo sharedInstance] updatePushMessage];
 
    [[UIApplication sharedApplication]  cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}



- (void)registerForRemoteNotification{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    
    NSString *token = [deviceToken stringWithHexBytes];
    NSLog(@"token =  %@",token);
    NSBundle* mainBundle = [NSBundle mainBundle];
    /*NSString* bundleIdentifier = */[[mainBundle infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:@"deviceToken"];
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json setObject:token forKey:@"pushToken"];

    
#ifdef _DEBUG
    [json setObject:@"apns_sandbox" forKey:@"channelId"];
#else
    [json setObject:@"apns" forKey:@"channelId"];
#endif
    [json setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"deviceId"];
    [json setObject:kAPPKey forKey:@"appId"];
    [json setObject:[[mainBundle infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"build"];
    NSMutableDictionary* tags = [[NSMutableDictionary alloc]init];
    [tags setValue:@"platform" forKey:@"key"];
    [tags setValue:@"iOS" forKey:@"value"];
    NSArray* array =[ [NSArray alloc]initWithObjects:tags, nil];
    [json setObject:array forKey:@"tags"];
    //tag   platform:ios
    
    [json setObject:[[UIDevice currentDevice]systemVersion] forKey:@"osVersion"];
    [json setObject:[[UIDevice currentDevice] name] forKey:@"deviceName"];
    [json setObject:@"IOS" forKey:@"osName"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    HTTPRequest *request = [HTTPRequest requestWithURL:[NSURL URLWithString:kPushServerRegisterUrl]];
    
    [request appendPostData:jsonData];
    [request setRequestMethod:@"PUT"];
    [request startAsynchronous];
    
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"获取推送token失败:%@", error_str);
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"" forKey:@"deviceToken"];
}


// this happens while we are running ( in the background, or from within our own app )
// only valid if cube-ios-Info.plist specifies a protocol to handle
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url{
    if (!url) {
        return NO;
    }
    
    // calls into javascript global function 'handleOpenURL'
    
    //下面两句由fanty 注掉，看上去不似是用得着
//    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
//    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    
    return YES;
}

// repost the localnotification using the default NSNotificationCenter so multiple plugins may respond
- (void) application:(UIApplication*)application
   didReceiveLocalNotification:(UILocalNotification*)notification{
  
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    //iphone只支持竖屏显示
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        NSUInteger supportedInterfaceOrientations =  (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) ;
        return supportedInterfaceOrientations;
    }
}




- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application{
    
    NSLog(@"applicationDidReceiveMemoryWarning");
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

-(void)postOpreateLog{
    NSArray * array = [OperateLog findAllLog];
    if([array count]<1){
        [self performSelector:@selector(postOpreateLog) withObject:nil afterDelay:60.0f];
        return;
    }
    NSMutableArray *dictArray = [[NSMutableArray alloc]initWithCapacity:0];
    for (OperateLog *log in array) {
        NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
        if([log.action length]>0)
            [dictionary setObject:log.action forKey:@"action"];
        else{
            NSLog(@"postOpreateLog empty 1");
        }
        if([log.appName length]>0)
            [dictionary setObject:log.appName forKey:@"appName"];
        else{
            NSLog(@"postOpreateLog empty 2");

        }
        if([log.moduleName length]>0)
            [dictionary setObject:log.moduleName forKey:@"moduleName"];
        else{
            NSLog(@"postOpreateLog empty 3");

        }
        if([log.username length]>0)
            [dictionary setObject:log.username forKey:@"username"];
        else{
            NSLog(@"postOpreateLog empty 4");

        }
        if([log.datetime length]>0)
            [dictionary setObject:log.datetime forKey:@"datetime"];
        else{
            NSLog(@"postOpreateLog empty 5");

        }
        [dictionary setObject:@"" forKey:@"className"];
        [dictionary setObject:@"" forKey:@"methodName"];
        [dictArray addObject:dictionary];
    }
    NSString *json = [dictArray JSONString];
   // NSLog(@"%@",json);
    dictArray=nil;
    
    FormDataRequest *request =[FormDataRequest requestWithURL:[NSURL URLWithString:[kServerURLString stringByAppendingFormat:@"%s","/csair-monitor/api/monitor/saveAll"]]];
    [request setPostValue:json forKey:@"postString"];
//    [request setPostValue:json forKey:@"entitysJson"];
    [request setPostValue:kAPPKey forKey:@"appKey"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"sessionKey"];

    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:1];
    [dict setObject:array forKey:@"array"];
    [request setUserInfo:dict];
    dict=nil;
    
    __block FormDataRequest*  __request=request;
    [request setFailedBlock:^{
        NSLog(@"失败");
        
        [self performSelector:@selector(postOpreateLog) withObject:nil afterDelay:60.0f];
    }];
    
    [request setCompletionBlock:^{
        if([__request responseStatusCode] == 200){
            NSArray *array = [[__request userInfo] valueForKey:@"array"];
            for (OperateLog *log in array) {
                [log remove];
            }
            NSLog(@"success.....................");
            
        }
        [self performSelector:@selector(postOpreateLog) withObject:nil afterDelay:60.0f];
    }];
    
    [request startAsynchronous];
    //    [request release];
    
}

-(void)updateCheckInTags{
    @autoreleasepool {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray* privileges = [defaults objectForKey:@"privileges"];
        NSString* updateTags =@"{";
        if ([privileges count]>0) {
            NSString* privilegeStr = @"";
            for (NSDictionary* privilege in privileges) {
                if([[privilege objectForKey:@"name"] isEqual:[NSNull null]])
                {
                    continue;
                }
                NSString* name = [privilege objectForKey:@"name"];
                if ([name length] > 0) {
                    privilegeStr = [privilegeStr stringByAppendingFormat:@"%@,",[privilege objectForKey:@"name"]];
                }
                
            }
            if ([privilegeStr length] > 0 ) {
                privilegeStr =  [privilegeStr substringToIndex:[privilegeStr length] -1 ];
                updateTags = [updateTags stringByAppendingFormat:@"privileges=%@",privilegeStr];
                updateTags = [updateTags stringByAppendingString:@","];
                
            }
        }
        if ([updateTags length]> 0) {
            NSString* sex = [defaults valueForKey:@"sex"];
            if (sex) {
                updateTags= [updateTags stringByAppendingFormat:@"sex=%@",sex];
                updateTags = [updateTags stringByAppendingString:@","];
            }
            
        }
        if ([updateTags length] > 1 ) {
            updateTags =  [updateTags substringToIndex:[updateTags length] -1 ];
            updateTags = [updateTags stringByAppendingString:@"}"];
            NSString* urlStr = kUpdatePushTagsUrl;
            NSString *deviceID = [[UIDevice currentDevice] uniqueDeviceIdentifier];
            ASIFormDataRequest * tagRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
            [tagRequest setPostValue:deviceID forKey:@"deviceId"];
            [tagRequest setPostValue:kAPPKey forKey:@"appId"];
            [tagRequest setPostValue:updateTags forKey:@"tags"];
            [tagRequest setRequestMethod:@"PUT"];
            [tagRequest startAsynchronous];
        }
    }
}

-(void)updateCollectionFriends{
    [IMServerAPI getCollectIMFriends:^(BOOL status,NSArray* friends){
        if(status){
            ChatLogic* logic=[[ChatLogic alloc] init];
            [logic addFaviorersInContacts:friends];
            logic=nil;
        }
    }];
}

-(void)didLogin{
 
        [self setupXmppStream];
    [self updateCheckInTags];
    [self updateCollectionFriends];
    
    //开启访问 获取到未收到的推送信息
    [[PushGetMessageInfo sharedInstance] updatePushMessage];
    [navControl popToRootViewControllerAnimated:NO];
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone){
        [self.navControl popToRootViewControllerAnimated:NO];
        
        Main_IphoneViewController* main=[[Main_IphoneViewController alloc] init];
//         UINavigationController *__navControl =[[[NSBundle mainBundle] loadNibNamed:@"MainNewWindow" owner:self options:nil] objectAtIndex:0];
//        self.window.rootViewController = __navControl;
        main.navController=self.navControl;
        UIView* view=main.view;
        view=nil;
        main=nil;  
    }else{
        
        [self.navControl popToRootViewControllerAnimated:NO];
        MainViewViewController* main=[[MainViewViewController alloc] init];
        main.navController=self.navControl;
        //this isvery import
        UIView* view=main.view;
        view=nil;
        //
        main=nil;
    }
}



-(void)setupXmppStream{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if (!xmpp) {
        xmpp = [[XMPPIMActor alloc]initWithDelegate:self];
    }
    xmpp.islogin = YES;
    xmpp.loginUserStr = [defaults objectForKey:@"LoginUser"];
    [xmpp setupXmppStream];
}


-(void)setupXmppSucces{
    
    NSLog(@"setupXmppSucces--");
}


-(void)setupUnsucces{
    NSString *message = [NSString stringWithFormat:@"ICube后台服务初始化失败"];
    
    UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [msg show];
}

-(void)setupError:(NSError*)aError{
    NSString *message = [NSString stringWithFormat:@"服务器出错,无法连接"];
    
    UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [msg show];
}


-(void)applicationWillTerminate:(UIApplication *)application{
    [self.xmpp.managedObjectContext save:nil];
    [self releasePushSound];
}
//推送提示音
-(void)ativatePushSound{
    
    //    AudioServicesPlaySystemSound(_soundFileObject);
    AudioServicesPlayAlertSound(_soundFileObject);
}
//引用提示音
-(void)referencePushSound{
    NSURL *tapSound = [NSURL URLWithString:@"/System/Library/Audio/UISounds/sms-received1.caf"];
    _soundFileURLRef = (CFURLRef) CFBridgingRetain(tapSound);
    AudioServicesCreateSystemSoundID (_soundFileURLRef,&_soundFileObject);
}
//释放
-(void)releasePushSound{
    AudioServicesDisposeSystemSoundID (_soundFileObject);
    CFRelease (_soundFileURLRef);
}
@end
