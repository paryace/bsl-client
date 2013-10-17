//
//  SettingMainViewController.m
//  cube-ios
//
//  Created by 东 on 13-3-20.
//
//

#import "SettingMainViewController.h"
#import "AboutViewController.h"
#import "SetttingIMViewController.h"
#import "CubeApplication.h"
#import "CubeModule.h"
#import "AsyncImageView.h"
#import "IconButton.h"
#import "NSFileManager+Extra.h"

@interface SettingMainViewController ()<UITableViewDataSource,UITableViewDelegate,CheckUpdateDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) NSMutableArray* settingSource;

-(void)notificationDidExist;
@end

@implementation SettingMainViewController
@synthesize delegate;
@synthesize selectedModule;
@synthesize settingSource;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        
        
         if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
         self.edgesForExtendedLayout = UIRectEdgeNone;
         self.extendedLayoutIncludesOpaqueBars = NO;
         self.modalPresentationCapturesStatusBarAppearance = YES;
         }
        

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidExist) name:@"LOGOUTSENDEXITNOTIFICATION" object:nil];
    }

    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor clearColor];
    
    self.title= @"设置";
    
    @autoreleasepool {
        NSMutableArray* array=[[NSMutableArray alloc]init];
        self.settingSource = array;
        array=nil;
        
        titleArray = [[NSArray alloc]initWithObjects:@"系统设置",@"模块设置", nil];
        
        NSMutableArray* firstArray = [[NSMutableArray alloc]init];
        
        NSArray* array1 = [[NSArray alloc]initWithObjects:@"更新版本",@"setting_update.png", nil];
        NSArray* array2 = [[NSArray alloc]initWithObjects:@"关于我们",@"setting_about.png", nil];
        NSArray* array3 = [[NSArray alloc]initWithObjects:@"即时通讯",@"setting_about.png", nil];
        
        [firstArray addObject:array1];
        [firstArray addObject:array2];
        [firstArray addObject:array3];
        
        [settingSource addObject:firstArray];
        
        firstArray=nil;
        
        
        NSMutableArray* secondArray = [[NSMutableArray alloc]init];

        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        CubeApplication *cubeApp = [CubeApplication currentApplication];
        for (CubeModule* module in  cubeApp.modules) {
            NSURL* moduleUrl =[module runtimeURL];
            NSURL* settingsFileURL = [moduleUrl URLByAppendingPathComponent:@"settings.html"];
            if ([fileManager fileExistsAtPath:[settingsFileURL path]]) {
                [secondArray addObject:module];
            }
        }
        if([secondArray count]>0){
            [settingSource addObject:secondArray];
        }
        
        secondArray=nil;
        
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 320:640,44)];
        //添加退出登陆按钮
        
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 14:28, 0, UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 292: 484, 44)];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"setting_exitBg.png"] forState:UIControlStateNormal];
        [btn setTitle:@"登出当前账号" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(exitBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [footerView addSubview:btn];
        
        self.settingTableView.delegate = self;
        self.settingTableView.dataSource  = self;
        self.settingTableView.tableFooterView = footerView;
        footerView=nil;
        
        if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad ) {
            //添加关闭按钮
            
                UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 43, 30)];
                [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn.png"] forState:UIControlStateNormal];
                [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_active.png"] forState:UIControlStateSelected];
                [navRightButton setTitle:@"关闭" forState:UIControlStateNormal];
                [[navRightButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
                [navRightButton addTarget:self action:@selector(closeSettingView) forControlEvents:UIControlEventTouchUpInside];
                
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
            
        }
        
        uc = [[UpdateChecker alloc] initWithDelegate:self];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];

    self.settingTableView=nil;
    self.settingSource=nil;
    uc=nil;
}

- (void)dealloc {
    self.settingTableView=nil;
    self.settingSource=nil;
    uc=nil;
}


-(void)closeSettingView{
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        [[self presentingViewController] dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    }
}

//========= tableview delegate start ===============
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[settingSource objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [settingSource count];
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if(cell== nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
    }
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0 ) {
        
        NSArray* array=[settingSource objectAtIndex:[indexPath section]];
        array=[array objectAtIndex:[indexPath row]];
        NSString* text=[array objectAtIndex:0];
        NSString* icon=[array objectAtIndex:1];
        cell.textLabel.text = text;
        UIImageView* imageview  = [[UIImageView alloc] initWithFrame:CGRectMake(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 25 : 50, 12.5, 20,20)];
        imageview.image = [UIImage imageNamed: icon];
        
        [cell addSubview:imageview];
    }
    else if([indexPath section]==1){
        NSArray* array=[settingSource objectAtIndex:[indexPath section]];
        CubeModule* model=[array objectAtIndex:[indexPath row]];
        NSString* text=model.name;
        cell.textLabel.text = text;
        AsyncImageView* imageview  = [[AsyncImageView alloc] initWithFrame:CGRectMake(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 25 : 50, 12.5, 20,20)];
        [imageview loadImageWithURLString:model.iconUrl];
        [cell addSubview:imageview];

    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString* title = @"";
    title= [titleArray objectAtIndex:section];
    return  title;
}

//选中cell后的回调函数
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0 ) {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            if ((BOOL)[defaults objectForKey:@"offLineSwitch"]) {
                NSString *message = [NSString stringWithFormat:@"离线模式不能更新"];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"版本更新" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [av show];
                return;
            }
            
            [uc check];
        }else if(indexPath.row == 1){
            AboutViewController* aboutViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:aboutViewController animated:YES];
        }else if(indexPath.row == 2){
            SetttingIMViewController* setttingIMViewController = [[SetttingIMViewController alloc]initWithNibName:@"SetttingIMViewController" bundle:nil];
            [self.navigationController pushViewController:setttingIMViewController animated:YES];
        }
    }
    //    else if(indexPath.section == 1){
    //        if (indexPath.row ==0 ) {
    //            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否上传本机模块信息覆盖服务器配置信息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"上传", nil];
    //            alertView.tag = 101;
    //            [alertView show];
    //            [alertView release];
    //
    //        }else{
    //            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否同步服务器的配置信息覆盖本地模块信息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"同步", nil];
    //            alertView.tag = 102;
    //            [alertView show];
    //            [alertView release];
    //        }
    //    }
    else{
        CubeModule * module = [[settingSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        @autoreleasepool {
            NSDictionary *missingModules = [module missingDependencies];
            NSArray *needInstall = [missingModules objectForKey:kMissingDependencyNeedInstallKey];
            NSArray *needUpgrade = [missingModules objectForKey:kMissingDependencyNeedUpgradeKey];
            
            if ([needInstall count] > 0 || [needUpgrade count] > 0) {
                NSMutableString *message = [[NSMutableString alloc] init];
                
                if([needInstall count] > 0){
                    
                    [message appendString:@"需要安装以下模块:\n"];
                    for ( NSString *dependency in needInstall) {
                        CubeModule *m = [[CubeApplication currentApplication] availableModuleForIdentifier:dependency];
                        if(m!=nil)
                            [message appendFormat:@"%@(build:%d)\n", m.name,m.build];
                        else
                            [message appendFormat:@"%@\n", dependency];
                    }
                    
                }
                
                if( [needUpgrade count] > 0){
                    
                    [message appendString:@"需要升级以下模块:\n"];
                    for ( NSString *dependency in needUpgrade) {
                        CubeModule *m = [[CubeApplication currentApplication] moduleForIdentifier:dependency];
                        if(m!=nil)
                            [message appendFormat:@"%@(build:%d)\n", m.name,m.build];
                        else
                            [message appendFormat:@"%@\n", dependency];
                    }
                }
                
                self.selectedModule = module.identifier;
                UIAlertView *dependsAlert = [[UIAlertView alloc] initWithTitle:@"缺少依赖模块"
                                                                       message:message
                                                                      delegate:self
                                                             cancelButtonTitle:@"确定" otherButtonTitles:/*@"安装", */nil];
                [dependsAlert show];
                message=nil;
                return;
            }
        }
        
        //植入界面
        if (!cubeWebViewController) {
            cubeWebViewController  = [[CubeWebViewController alloc] init];
        }
        cubeWebViewController.title=module.name;
        
        
        NSString * moduleIndex = [[[module runtimeURL] URLByAppendingPathComponent:@"index.html"] absoluteString];
        cubeWebViewController.startPage = [NSString stringWithFormat:@"%@#%@/settings", moduleIndex, module.identifier];
        
        [cubeWebViewController loadWebPageWithModuleIdentifier:module.identifier didFinishBlock: ^(){
            NSLog(@"finish loading");
            [self.navigationController.navigationBar setHidden:NO];
            
            [self.navigationController pushViewController:cubeWebViewController animated:YES];
            
            
            cubeWebViewController = nil;
        }didErrorBlock:^(){
            NSLog(@"error loading");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设置页模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            cubeWebViewController = nil;
        }];
    }
    
}


-(void)updateUnavailable{
    NSString *message = [NSString stringWithFormat:@"已是最新版本"];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"版本更新" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [av show];
    av=nil;
}

-(void)updateError:(NSError*)aError
{
    NSString *message = [NSString stringWithFormat:@"更新出错，请检查网络"];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"版本更新" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [av show];
    av=nil;
}



#pragma mark - 上传用户的配置信息


#pragma mark - 同步用户的配置信息



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101 ) {
        //上传方法  
        return;
    }else if(alertView.tag == 102 ){
        //下载方法
        return;
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ) {
        return  interfaceOrientation ==  UIInterfaceOrientationPortrait;
    }
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


//========= tableview delegate end   ===============

- (IBAction)exitBtn:(id)sender {
    if ([delegate respondsToSelector:@selector(ExitLogin)]) {
        [delegate ExitLogin];
    }
    
}

-(void)notificationDidExist{
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        [[self presentingViewController] dismissModalViewControllerAnimated:NO];
    }
    else
    {
        [[self parentViewController] dismissModalViewControllerAnimated:NO];
    }
}
@end
