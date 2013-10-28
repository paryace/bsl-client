//
//  Main_IphoneViewController.m
//  cube-ios
//
//  Created by 东 on 8/2/13.
//
//

#import "Main_IphoneViewController.h"
#import "CubeWebViewController.h"
#import "NSFileManager+Extra.h"
#import "SettingMainViewController.h"
#import "DownLoadingDetialViewController.h"
#import "MessageRecord.h"
#import "JSONKit.h"
#import "NSFileManager+Extra.h"
#import "ServerAPI.h"
#import "FMDBManager.h"
#import "HTTPRequest.h"
#import "AutoDownLoadRecord.h"
#import "OperateLog.h"
#import "AutoShowRecord.h"
#import "SVProgressHUD.h"
#import "SettingMainViewController.h"

#import "KKProgressToolbar.h"
#import "CudeModuleDownDictionary.h"


@interface Main_IphoneViewController ()<DownloadCellDelegate,SettingMainViewControllerDelegate,UIGestureRecognizerDelegate,KKProgressToolbarDelegate>{
    KKProgressToolbar* statusToolbar;
    BOOL isFirst;
    
    CubeWebViewController *bCubeWebViewController;
    int allDownCount;
    
    UIAlertView*  singleAlert;
    
    UIAlertView* failedAlert;
}

@property(strong,nonatomic) id selfObj;

@end

@implementation Main_IphoneViewController
@synthesize navController;
@synthesize aCubeWebViewController;
-(id)init{
    self=[super init];
    if(self){
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showView:) name:@"SHOW_DETAILVIEW" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMainView) name:@"SHOW_MAINVIEW" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSetting) name:@"SHOW_SETTING_VIEW" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:@"module_badgeCount_change" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleDidInstalled:) name:CubeModuleInstallDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:@"MESSAGE_RECORD_DID_Change_NOTIFICATION" object:nil];
        //收到消息时候的广播
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:MESSAGE_RECORD_DID_SAVE_NOTIFICATION object:nil];
        //收到好友消息时候
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleInstallFail:) name:CubeModuleDownloadDidFailNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteModuleFromNotification:) name:KNOTIFICATION_DETIALPAGE_DELETESUCCESS object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissView) name:@"DISMISS_VIEW" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleDidInstalled:) name:KNOTIFICATION_DETIALPAGE_INSTALLSUCCESS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didProgressUpdate:) name:@"queue_module_download_progressupdate" object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleSysFinsh) name:CubeSyncFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleSysFinsh) name:CubeSyncFailedNotification object:nil];
        

    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.selfObj=self;

    aCubeWebViewController = [[CubeWebViewController alloc]init];
    aCubeWebViewController.showCloseButton=YES;
    aCubeWebViewController.title=@"登录";
    aCubeWebViewController.wwwFolderName = @"www";
    NSURL* fileUrl = nil;
#ifdef MOBILE_BSL
    aCubeWebViewController.startPage =   [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"home/index.html"] absoluteString];
    fileUrl = [[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"home/index.html"];
#else
    aCubeWebViewController.startPage =   [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"phone/index.html"] absoluteString];
    fileUrl =[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"phone/index.html"];
#endif
    CGRect rect=self.view.bounds;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
        rect.origin.y=20.0f;
        rect.size.height-=20.0f;
    }
    aCubeWebViewController.view.frame = rect;
    [self.view addSubview:aCubeWebViewController.view];
    aCubeWebViewController.webView.scrollView.bounces=NO;
    [aCubeWebViewController loadWebPageWithUrl: [fileUrl absoluteString] didFinishBlock: ^(){
        [self.navController pushViewController:self animated:NO];
        self.navController=nil;
        [SVProgressHUD dismiss];
        aCubeWebViewController.closeButton.hidden = YES;
        [aCubeWebViewController viewWillAppear:NO];
        [aCubeWebViewController viewDidAppear:NO];
        [self addBadge];
        self.selfObj=nil;
        
    }didErrorBlock:^(){
        [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
        failedAlert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"首页模块加载失败。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [failedAlert show];
        self.navController=nil;
        self.selfObj=nil;
    }];
	
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
    [singleAlert dismissWithClickedButtonIndex:0 animated:NO];
    singleAlert=nil;
    failedAlert=nil;
    
    aCubeWebViewController=nil;
    
    bCubeWebViewController=nil;
    self.selectedModule=nil;
}




- (void)dealloc{
    [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
    failedAlert=nil;
    
    [singleAlert dismissWithClickedButtonIndex:0 animated:NO];
    singleAlert=nil;

    aCubeWebViewController=nil;
    bCubeWebViewController=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.selectedModule=nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden{
    return NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addBadge];
   [self.navigationController setNavigationBarHidden:YES animated:YES];
}


//SHOW_MAINVIEW
-(void)showMainView{
    aCubeWebViewController.closeButton.hidden = YES;
}

-(void)addBadge{
    if (aCubeWebViewController) {
        for (  CubeModule* module in [[CubeApplication currentApplication] modules]) {
            if (!module.hidden) {
                NSString* moduleIdentifier = module.identifier;
                int count = [moduleIdentifier  isEqualToString:@"com.foss.message.record"] ? [MessageRecord countAllAtBadge] :[MessageRecord countForModuleIdentifierAtBadge:moduleIdentifier];
                //判断模块是否需要显示右上角的数字
                if(![module.moduleBadge isEqualToString:@"1"])
                {
                    [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"receiveMessage('%@',%d,true);",moduleIdentifier,count]];
                }else{
                    [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"receiveMessage('%@',%d,true);",moduleIdentifier,0]];
                }
            }
        }
    }
}

-(void)dismissView{
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate) withObject:nil afterDelay:0.7f];
    }
}



-(void)moduleSysFinsh{
    if (!isFirst) {
        //检测是否需要自动安装
        [self autoShowModule];
        isFirst = true;
    }
    [self checkModules];
}

-(void)checkModules{
    //检测是否需要自动安装
    
    NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];
    NSString* username=[defaults valueForKey:@"username"];
    
    NSString* tip=[username stringByAppendingString:@"_notFirstLogin"];
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:tip]!=nil){

        [self checkAutoUpdate];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:tip];

    @autoreleasepool {
#ifndef MOBILE_BSL
        NSMutableArray *downloadArray = [[CubeApplication currentApplication] downloadingModules];
#else
        NSMutableArray *downloadArray = [[CubeApplication currentApplication] availableModules];
#endif
        if([downloadArray count]>0){
            NSMutableString *message = [[NSMutableString alloc] init];
            [message appendString:@"检测到有以下模块需要下载:\n"];
            for(CubeModule *module in downloadArray){
                [message appendFormat:@"%@\n", module.name];
            }
            
            [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
            failedAlert=nil;
            
            [singleAlert dismissWithClickedButtonIndex:0 animated:NO];
            
            singleAlert  =[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"立即下载" otherButtonTitles:@"取消",nil];
            singleAlert.tag =830;
            [singleAlert show];
            
            return;
        }
        else
        {
            [self checkAutoUpdate];
        }
    }
    
}

-(void)checkAutoUpdate{
    NSMutableArray *updateModules = [[CubeApplication currentApplication] updatableModules];
    if(updateModules.count>0){
        @autoreleasepool {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableString *message = [[NSMutableString alloc] init];
            [message appendString:@"以下模块可以更新:\n"];
            for(CubeModule *module in updateModules){
                [message appendFormat:@"%@ %@\n", module.name,module.version];
            }
            //        [defaults setBool:NO forKey:@"firstTime"];
            if(![defaults boolForKey:@"firstTime"]){
                [defaults setBool:YES forKey:@"firstTime"];
                [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
                failedAlert=nil;
                [singleAlert dismissWithClickedButtonIndex:0 animated:NO];
                singleAlert  =[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
                singleAlert.tag =829;
                [singleAlert show];
            }
            message=nil;
        }
    }
}

//异步判断哪个模块打开
-(void)autoShowModule
{
    NSString *userName = [[NSUserDefaults standardUserDefaults]valueForKey:@"username"];
    NSMutableArray * modulesArray = [[CubeApplication currentApplication]modules];
    for (CubeModule *module in modulesArray) {
        if([module moduleIsInstalled])
        {
            if(module.isAutoShow && module.privileges )
            {
                //建表保存用户，模块名 弹出时间，判断时间间隔内不再弹出模块
                if(![[FMDBManager getInstance].database tableExists:@"AutoShowRecord"])
                {
                    AutoShowRecord *record = [[AutoShowRecord alloc]init];
                    [[FMDBManager getInstance]createTable:@"AutoShowRecord" withObject:record];
                }
                
                if(![[FMDBManager getInstance]recordIsExist:module.identifier  withtableName:@"AutoShowRecord" withConditios:userName])
                {
                    [self showWebViewModue:module];
                    AutoShowRecord *newRecord = [[AutoShowRecord alloc]init];
                    newRecord.identifier = module.identifier;
                    newRecord.userName = userName;
                    long time = [[NSDate date]timeIntervalSince1970];
                    newRecord.showTime = [NSString stringWithFormat:@"%ld",time];
                    [[FMDBManager getInstance]insertToTable:newRecord withTableName:@"AutoShowRecord" andOtherDB:nil];
                    
                    break;
                }
                else
                {
                    NSString *sql = [NSString stringWithFormat:@"select * from AutoShowRecord where identifier='%@' and userName='%@'",module.identifier,userName];
                    FMResultSet *result = [[[FMDBManager getInstance] database] executeQuery:sql];
                    while([result next])
                    {
                        NSString * showTimeTmp = [result objectForColumnName:@"showTime"];
                        long long showTime = [showTimeTmp longLongValue];
                        
                        if([module.timeUnit isEqualToString:@"H"])
                        {
                            long currentTime = [[NSDate date]timeIntervalSince1970];
                            if((currentTime-showTime)>module.showIntervalTime*60*60)
                            {
                                [self showWebViewModue:module];
                                //更新表
                                [self updateAuthoShowTime:module.identifier];
                                return;
                            }
                            
                        }
                        else if([module.timeUnit isEqualToString:@"M"])
                        {
                            long currentTime = [[NSDate date]timeIntervalSince1970];
                            if((currentTime-showTime)>module.showIntervalTime*60)
                            {
                                [self showWebViewModue:module];
                                //更新表
                                [self updateAuthoShowTime:module.identifier];
                                return;
                            }
                            
                        }
                        else if([module.timeUnit isEqualToString:@"S"])
                        {
                            
                            long currentTime = [[NSDate date]timeIntervalSince1970];
                            //                            NSLog(@"%ld------%ld-------%ld",currentTime,showTime,(currentTime-showTime));
                            if((currentTime-showTime)>module.showIntervalTime)
                            {
                                [self showWebViewModue:module];
                                //更新表
                                [self updateAuthoShowTime:module.identifier];
                                return;
                            }
                            
                        }
                        
                    }
                }
                
            }
        }
    }
}

-(void)moduleInstallFail:(NSNotification*)tion{
    if (statusToolbar) {
        int count = [self getDownMouleCount];
        NSLog(@"count =%d , allcount =%d   last = %d",count,allDownCount,allDownCount - count);
        if ( count <= 0 ) {
            [self stopUILoading];
        }else{
            [self startUILoading];
        }
    }
    CubeModule* cube = [tion object];
    cube.isDownloading = false;
    NSString * javaScript = [NSString stringWithFormat:@"updateProgress('%@',%d);",cube.identifier,101];
    [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
    
    [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
    failedAlert=nil;
    failedAlert=[[UIAlertView alloc] initWithTitle:@"网络连接失败，请稍后重试！" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [failedAlert show];
    failedAlert=nil;
    //if(![SVProgressHUD isVisible])
    //    [SVProgressHUD showErrorWithStatus:@"网络连接失败，请稍后重试！"];
}

-(void)updateAuthoShowTime:(NSString*)identifier{
    long currentTime = [[NSDate date]timeIntervalSince1970];
    NSString *userName = [[NSUserDefaults standardUserDefaults]valueForKey:@"username"];
    NSString *sql = [NSString stringWithFormat:@"update AutoShowRecord set showTime='%ld' where identifier='%@' and userName='%@'",currentTime,identifier,userName];
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDatabase *database = [[FMDBManager getInstance]database ];
        if (![database open])
        {
            [database open];
        }
        [database executeUpdate:sql];
    //});
}

#pragma mark - 皮肤功能

- (void)onclick:(int)index source:(NSArray *)source{
    if ([source count] > index) {
        NSString* name= [[source objectAtIndex:index]  objectForKey:@"name"];
        [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeTheme('%@');",name]];
    }
}


-(void)didProgressUpdate:(NSNotification *) notification{
    NSDictionary* dictionary = [notification userInfo];
    NSNumber* num = [dictionary objectForKey:@"newProgress"];
    NSString* key = [dictionary objectForKey:@"key"];
    float pro = [num floatValue]*100;
    int proInt = pro;
    NSString * javaScript = [NSString stringWithFormat:@"updateProgress('%@',%d);",key,proInt];
    [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
}

#pragma mark - 展示详情界面

//通过通知回调函数 显示需要暂时的view
-(void)showView:(NSNotification*)notification{
    NSArray* arguments = notification.object;
    NSString* identifier = [arguments objectAtIndex:0];
    NSString* type = [arguments objectAtIndex:1];
    CubeApplication *app = [CubeApplication currentApplication];
    CubeModule *module = [app moduleForIdentifier:identifier];
    if ([type isEqualToString:@"main"]) {
        //记录模块点击begin
        [OperateLog recordOperateLog:module];
        //end
        if([module.local length] >0){
            NSString* iphoneLocal;
            if ([module.local isEqualToString:@"DetailViewController"]) {
                iphoneLocal = @"iphoneVoiceMasterViewController";
            }else if([module.local isEqualToString:@"MessageRecord"]){
                iphoneLocal = @"MessageRecordTableViewController";
            }else if([module.local isEqualToString:@"XMPPFriends"]){
                ///*remove by fanty
                //iphoneLocal = @"XMPPFriendsViewController";
                
                iphoneLocal=@"FriendMainViewController";
            }else if([module.local isEqualToString:@"Announcement"]){
                iphoneLocal = @"AnnouncementTableViewController";
            }else{
                iphoneLocal = [module.local stringByAppendingString:@"ViewController"];
            }
            UIViewController *localController = (UIViewController *)[[NSClassFromString(iphoneLocal) alloc] init];
            if(localController==nil){
                [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
                failedAlert=nil;
                failedAlert=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@模块不存在",module.name] message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [failedAlert show];
                failedAlert=nil;
                return;
            }
            //[self.navigationController setNavigationBarHidden:NO animated:YES];
            [self.navigationController pushViewController:localController animated:YES];
            localController=nil;
            return;
        }else{
            [self showWebViewModue:module];
        }
    }else if ([type isEqualToString:@"install"] || [type isEqualToString:@"uninstall"] || [type isEqualToString:@"upgrade"]){
        //显示模块的详细信息
        CubeApplication *cubeApp = [CubeApplication currentApplication];
        NSMutableArray *modules  = [NSMutableArray array];
        
        [modules addObjectsFromArray:[cubeApp updatableModules]];
        [modules addObjectsFromArray:[cubeApp modules]];
        [modules addObjectsFromArray:[cubeApp availableModules]];

        DownLoadingDetialViewController *funDetialVC=[[DownLoadingDetialViewController alloc]init];
        //循环已安装列表
        BOOL isExit = false;
        for(CubeModule *each in [cubeApp modules]){
            if([each.identifier isEqualToString:identifier]){
                funDetialVC.curCubeModlue=each;
                isExit = true;
                funDetialVC.buttonStatus = InstallButtonStateInstalled;
                break;
            }
        }
        
        //循环更新列表
        if (!isExit) {
            for(CubeModule *each in [cubeApp updatableModules]){
                if([each.identifier isEqualToString:identifier]){
                    funDetialVC.curCubeModlue=each;
                    isExit = true;
                    funDetialVC.buttonStatus = InstallButtonStateUpdatable;
                    break;
                }
            }
        }
        
        
        //循环未安装列表
        if (!isExit) {
        for(CubeModule *each in [cubeApp availableModules]){
            if([each.identifier isEqualToString:identifier]){
                funDetialVC.curCubeModlue=each;
                isExit = true;
                funDetialVC.buttonStatus = InstallButtonStateUninstall;
                break;
            }
        }
        }
        
        funDetialVC.delegate = self;
        
        if(funDetialVC.curCubeModlue.isDownloading){
            funDetialVC.iconImage=[[IconButton alloc] initWithModule:funDetialVC.curCubeModlue stauts:IconButtonStautsDownloading delegate:nil];
            funDetialVC.iconImage.badgeView.hidden = YES;
            funDetialVC.iconImage.downloadProgressView.progress = funDetialVC.curCubeModlue.downloadProgress;
            funDetialVC.iconImage.category=funDetialVC.curCubeModlue.category;
            funDetialVC.buttonStatus = InstallButtonStateUpdating;
        }else
        {
            funDetialVC.iconImage =[[IconButton alloc] initWithModule:funDetialVC.curCubeModlue stauts:IconButtonStautsDownloadEnable delegate:nil];
            funDetialVC.iconImage.category=funDetialVC.curCubeModlue.category;
        }
        [self.navigationController pushViewController:funDetialVC animated:YES];
        funDetialVC=nil;

    }
}

-(void)showWebViewModue:(CubeModule*)module{
    //检查依赖包 是否已经安装
    @autoreleasepool {
        NSDictionary *missingModules = [module missingDependencies];
        NSArray *needInstall = [missingModules objectForKey:kMissingDependencyNeedInstallKey];
        NSArray *needUpgrade = [missingModules objectForKey:kMissingDependencyNeedUpgradeKey];
        
        if ([needInstall count] > 0 || [needUpgrade count] > 0) {
            NSMutableString *message = [[NSMutableString alloc] init];
            
            if([needInstall count] > 0){
                
                [message appendString:@"需要安装以下模块:\n"];
                for (NSString *dependency in needInstall) {
                    CubeModule *m = [[CubeApplication currentApplication] availableModuleForIdentifier:dependency];
                    if(m!=nil)
                        [message appendFormat:@"%@(build:%d)\n", m.name,m.build];
                    else
                        [message appendFormat:@"%@\n", dependency];
                }
                
            }
            
            if( [needUpgrade count] > 0){
                
                [message appendString:@"需要升级以下模块:\n"];
                for (NSString *dependency in needUpgrade) {
                    CubeModule *m = [[CubeApplication currentApplication] moduleForIdentifier:dependency];
                    if(m!=nil)
                        [message appendFormat:@"%@(build:%d)\n", m.name,m.build];
                    else
                        [message appendFormat:@"%@\n", dependency];
                }
                
            }
            
            self.selectedModule = module.identifier;
            [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
            failedAlert=nil;
            [singleAlert dismissWithClickedButtonIndex:0 animated:NO];
            singleAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ 缺少依赖模块",module.name]
                                                                   message:message
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定" otherButtonTitles:/*@"安装", */nil];
            [singleAlert show];
            singleAlert=nil;
            return;
        }
    }
    
    CGRect frame = self.view.frame;
    frame.size.width =CGRectGetHeight(self.view.frame)/2+2;
    frame.size.height= CGRectGetWidth(self.view.frame);
    
    [bCubeWebViewController.view removeFromSuperview];
    bCubeWebViewController=nil;
    bCubeWebViewController  = [[CubeWebViewController alloc] init];
    bCubeWebViewController.showCloseButton=YES;
    //记录html5模块点击begin
    [OperateLog recordOperateLog:module];
    //end
    bCubeWebViewController.title = module.name;
    [bCubeWebViewController loadWebPageWithModule:module  frame:frame  didFinishBlock: ^(){
        //如果webView加载成功  这显示放大缩小按钮
        bCubeWebViewController.webView.scrollView.bounces=NO;
        [self.navigationController pushViewController:bCubeWebViewController animated:YES];
        bCubeWebViewController.closeButton.hidden = NO;
        bCubeWebViewController=nil;
    }didErrorBlock:^(){
        NSLog(@"error loading %@", bCubeWebViewController.webView.request.URL);
        [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
        failedAlert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@模块加载失败。",bCubeWebViewController.title] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [failedAlert show];
        bCubeWebViewController=nil;
    }];
}


-(void)showSetting{
    SettingMainViewController *settingView = [[SettingMainViewController alloc]initWithNibName:@"SettingMainViewController" bundle:nil];
    settingView.modalPresentationStyle = UIModalPresentationFormSheet;
    settingView.delegate = self;
    [self.navigationController pushViewController:settingView animated:YES];
    settingView=nil;
}



#pragma mark - SettingView delegate
-(void)ExitLogin{
    [failedAlert dismissWithClickedButtonIndex:0 animated:NO];
    failedAlert=nil;
    [singleAlert dismissWithClickedButtonIndex:0 animated:NO];
    singleAlert = [[UIAlertView alloc] initWithTitle:@"退出登录" message:@"是否确认退出登录?" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    singleAlert.tag = 1;
    [singleAlert show];
}

#pragma mark - 退出登陆
-(void)logout{
    //退出登录清空CubeApplication中的数组
    CubeApplication *application = [CubeApplication currentApplication];
    [[application modules] removeLastObject];
    [[application availableModules] removeAllObjects];
    [[application updatableModules] removeAllObjects];
    [[application downloadingModules] removeAllObjects];
    [(AppDelegate *)[UIApplication sharedApplication].delegate showLoginView:NO];

}


#pragma mark - alerview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView isEqual:failedAlert]){
        failedAlert=nil;
        return;
    }
    singleAlert=nil;
    if(alertView.tag ==829){
        if(buttonIndex == 0){
            NSMutableArray *modules =[[CubeApplication currentApplication ]updatableModules];
            for (CubeModule *m in modules) {
                m.isDownloading = YES;
                [[CubeApplication currentApplication] installModule:m];
            }
        }else{
            [self  checkAutoUpdate];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    if(alertView.tag == 830){
#ifndef MOBILE_BSL
        NSMutableArray *downloadArray = [[CubeApplication currentApplication] downloadingModules];
#else
        NSMutableArray *downloadArray = [[CubeApplication currentApplication] availableModules];
#endif
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        self.navigationItem.hidesBackButton =YES;
//        self.navigationItem.leftBarButtonItem =nil;
//    
        if(![[FMDBManager getInstance].database tableExists:@"AutoDownLoadRecord"]){
            AutoDownLoadRecord *record = [[AutoDownLoadRecord alloc]init];
            [[FMDBManager getInstance] createTable:(@"AutoDownLoadRecord") withObject:record];
            record=nil;
        }
        if(downloadArray && downloadArray.count>0){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *records = [[NSMutableArray alloc]initWithCapacity:0];
            for(CubeModule *module in downloadArray){
                AutoDownLoadRecord *record = [[AutoDownLoadRecord alloc]init];
                [record setHasShow:@"1"];
                [record setIdentifier:module.identifier];
                [record setUserName:[defaults valueForKey:@"username"]];
                [records addObject:record];
                record=nil;
            }
            [[FMDBManager getInstance] batchInsertToTable:records withtableName:@"AutoDownLoadRecord"];
            //                [copyArray release];
        }
        //        });
        if(buttonIndex == 0)
        {
            
            if(downloadArray && downloadArray.count>0)
            {
               
                allDownCount = downloadArray.count;
                for(CubeModule *module in downloadArray){
                    module.isDownloading = YES;
                    [[CubeApplication currentApplication] installModule:module];
                }
                [[[CubeApplication currentApplication] downloadingModules] removeAllObjects];
                
                CGRect statusToolbarFrame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44);
                statusToolbar = [[KKProgressToolbar alloc] initWithFrame:statusToolbarFrame];
                statusToolbar.actionDelegate = self;
                [self.view addSubview:statusToolbar];
                
                 [self startUILoading];
            }
            return;
            
        }
        else
        {
            
            CubeApplication *cubeApp = [CubeApplication currentApplication];
            for(CubeModule *module in downloadArray){
                [[cubeApp availableModules] removeObject:module];
                module.isDownloading = NO;
//                [cubeApp uninstallModule:module];
            }
            [[[CubeApplication currentApplication] downloadingModules] removeAllObjects];
            return;
        }
        
    }
    
    
    //退出登录alert
    if (alertView.tag == 1 && buttonIndex== 0 ) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        HTTPRequest * request = [HTTPRequest requestWithURL:[NSURL URLWithString:[ServerAPI urlForlogout:[userDefaults objectForKey:@"token"]]]];
        
        [request startAsynchronous];
        [self logout];
    }
    
    if (buttonIndex==0) {
        CubeModule *module = [[CubeApplication currentApplication] moduleForIdentifier:self.selectedModule];
        //需要下载的模块
        NSArray *missingModules = [[module missingDependencies] objectForKey:kMissingDependencyNeedInstallKey];
        for (NSString *missingModule in missingModules) {
            CubeModule *am = [[CubeApplication currentApplication] availableModuleForIdentifier:missingModule];
            am.isDownloading = YES;
            [[CubeApplication currentApplication] installModule:am];
        }
        
        //需要升级的模块
        NSArray *needUpgradeModules = [[module missingDependencies] objectForKey:kMissingDependencyNeedUpgradeKey];
        for (NSString *needUpgradeModule in needUpgradeModules) {
            CubeModule *am = [[CubeApplication currentApplication] updatableModuleModuleForIdentifier:needUpgradeModule];
            am.isDownloading = YES;
            [[CubeApplication currentApplication] installModule:am];
        }
    }
}



- (void)downloadAtModuleIdentifier:(NSString *)identifier  andCategory:(NSString *)category;{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    CubeModule *module = [cubeApp availableModuleForIdentifier:identifier];
    if(!module){
        module = [cubeApp updatableModuleModuleForIdentifier:identifier];
    }
    [cubeApp installModule:module ];
}

-(void)deleteModuleFromNotification:(NSNotification*)tion{
    NSString *identifier = [tion object];

    //fanty 发现死循环
    /*
    [self deleteAtModuleIdentifier:identifier];
    */
    
    @autoreleasepool {
        CubeApplication *cubeApp = [CubeApplication currentApplication];
        CubeModule *m = [cubeApp moduleForIdentifier:identifier];
        NSMutableDictionary* moduleDictionary = [self modueToJson:m];
        NSString* JSO=   [[NSString alloc] initWithData:moduleDictionary.JSONData encoding:NSUTF8StringEncoding];
        NSString * javaScript = [NSString stringWithFormat:@"refreshModule('%@','uninstall','%@');",identifier,JSO ];
        [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
        JSO=nil;
        javaScript=nil;
    }

}

- (void)deleteAtModuleIdentifier:(NSString *)identifier{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    CubeModule *m = [cubeApp moduleForIdentifier:identifier];
    m.isDownloading = false;
    NSMutableDictionary* moduleDictionary = [self modueToJson:m];
    NSString* JSO=   [[NSString alloc] initWithData:moduleDictionary.JSONData encoding:NSUTF8StringEncoding];
    NSString * javaScript = [NSString stringWithFormat:@"refreshModule('%@','uninstall','%@');",identifier,JSO ];
    [cubeApp uninstallModule:m didFinishBlock:^(){
        [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
    }];
}

-(void)inStalledModuleIdentifierr:(NSString *)identifier{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    CubeModule *m = [cubeApp moduleForIdentifier:identifier];
    NSMutableDictionary* moduleDictionary = [self modueToJson:m];
    NSString* JSO=   [[NSString alloc] initWithData:moduleDictionary.JSONData encoding:NSUTF8StringEncoding];
    NSString * javaScript = [NSString stringWithFormat:@"refreshModule('%@','install','%@');",m.identifier,JSO];
    [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
}

-(void)moduleDidInstalled:(NSNotification*)note{
    if (statusToolbar) {
        int count = [self getDownMouleCount];
        NSLog(@"count =%d , allcount =%d   last = %d",count,allDownCount,allDownCount - count);
        if ( count <= 0 ) {
            [self stopUILoading];
        }else{
            [self startUILoading];
        }
    }
    
    CubeModule *newModule = [note object];
    newModule.isDownloading = false;
    if (newModule) {
        @autoreleasepool {
            NSMutableDictionary* moduleDictionary = [self modueToJson:newModule];
            NSString* JSO=   [[NSString alloc] initWithData:moduleDictionary.JSONData encoding:NSUTF8StringEncoding];
            NSString * javaScript = @"";
            if (newModule.installType) {
                javaScript = [NSString stringWithFormat:@"refreshModule('%@','upgrade','%@');",newModule.identifier,JSO];
            }else{
                javaScript = [NSString stringWithFormat:@"refreshModule('%@','install','%@');",newModule.identifier,JSO];
            }
            newModule.installType = nil;
            [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
            
            if (!newModule.hidden) {
                NSString * mainScript = [NSString stringWithFormat:@"refreshMainPage('%@','main','%@');",newModule.identifier,JSO];
                [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:mainScript];
            }
            
            JSO=nil;
        }
    }
    
    
    
}


-(NSMutableDictionary*)modueToJson:(CubeModule* )each{
    if(each){
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString *token =  [defaults objectForKey:@"token"];
        
        NSMutableDictionary *jsonCube = [NSMutableDictionary dictionary];
        [jsonCube setObject:[NSNumber numberWithBool:each.hidden] forKey:@"hidden"];
        [jsonCube  setObject:each.version forKey:@"version"];
        [jsonCube  setObject:each.releaseNote forKey:@"releaseNote"];
        [jsonCube  setObject:each.category forKey:@"category"];
        if(!each.iconUrl)
        {
            [jsonCube  setObject:[@"" stringByAppendingFormat:@"?sessionKey=%@&appKey=%@",token,kAPPKey]  forKey:@"icon"];
        }
        else
        {
            [jsonCube  setObject:[each.iconUrl stringByAppendingFormat:@"?sessionKey=%@&appKey=%@",token,kAPPKey]  forKey:@"icon"];
        }
        [jsonCube  setObject:each.identifier forKey:@"identifier"];
        [jsonCube  setObject:!each.local?@"":each.local forKey:@"local"];
        [jsonCube  setObject:each.name forKey:@"name"];
        //=========================================
        int count = 0 ;
        if (![each.moduleBadge isEqualToString:@"1"]) {
            
            if ([each.identifier  isEqualToString:@"com.foss.message.record"]) {
                count  =[MessageRecord countAllAtBadge];
            }else{
                count = [MessageRecord countForModuleIdentifierAtBadge:each.identifier];
            }
        }
       [jsonCube  setObject: [NSNumber numberWithInt:count] forKey:@"msgCount"];
        [jsonCube  setObject: [NSNumber numberWithInt:0] forKey:@"progress"];
        //=========================================
        [jsonCube  setObject: [NSNumber numberWithInteger:each.build] forKey:@"build"];
         [jsonCube setObject:[NSNumber numberWithInt:each.sortingWeight] forKey:@"sortingWeight"];
        if ([self isUpdateModule:each.identifier]) {
            [jsonCube  setObject:  [NSNumber numberWithBool:YES] forKey:@"updatable"];
        }else{
            [jsonCube  setObject:  [NSNumber numberWithBool:NO] forKey:@"updatable"];
        }
        return jsonCube;
    }else{
        return nil;
    }
}



//根据模块的Identifier判断当前模块是否是可更新的模块
-(Boolean)isUpdateModule:(NSString*)moduleIdentifier{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    CubeModule *module = [cubeApp updatableModuleModuleForIdentifier:moduleIdentifier];
    if (module) {
        return YES;
    }
    return NO;
}
    
    
#pragma mark -- KKProgressToolbar delegate
- (void)didCancelButtonPressed:(KKProgressToolbar *)toolbar {
    [statusToolbar hide:YES completion:^(BOOL finished) {
        
    }];
}

-(void)startUILoading{
    int count =[self getDownMouleCount];
    statusToolbar.statusLabel.text = [NSString stringWithFormat:@"正在下载... %d/%d",(allDownCount - count) ,allDownCount];
    
    
    statusToolbar.progressBar.progress = 1-(float)count/(float)allDownCount;
    [statusToolbar show:YES completion:^(BOOL finished) {
        CGRect frame = self.view.frame ;
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            frame.origin.y=20.0f;
            frame.size.height-=20.0f;
        }
        
        frame.size.height -= 44;
        aCubeWebViewController.view.frame = frame;
    }];
}
    
-(void)stopUILoading{
    [statusToolbar hide:YES completion:^(BOOL finished) {
        CGRect frame = self.view.frame ;
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            frame.origin.y=20.0f;
            frame.size.height-=20.0f;
        }
        aCubeWebViewController.view.frame = frame;
        [statusToolbar removeFromSuperview];
        statusToolbar = nil;
    }];
}
-(int)getDownMouleCount{
    return [[CudeModuleDownDictionary shareModuleDownDictionary]  count];
}
    
@end
