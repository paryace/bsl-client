//
//  DeviceRegister_IphoneControllerViewController.m
//  bsl
//
//  Created by hibad(Alfredo) on 13/10/31.
//
//

#import "DeviceRegister_IphoneControllerViewController.h"
#import "NSFileManager+Extra.h"

@interface DeviceRegister_IphoneControllerViewController ()

@end

@implementation DeviceRegister_IphoneControllerViewController
@synthesize aCubeWebViewController = _aCubeWebViewController;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkDRFinish) name:@"DeviceRegistFinished" object:nil];
    
    
    self.aCubeWebViewController=nil;
    _aCubeWebViewController = [[CubeWebViewController alloc] init];
	// Do any additional setup after loading the view.
    self.aCubeWebViewController.title=@"设备注册";
    self.aCubeWebViewController.wwwFolderName = @"www";
    self.aCubeWebViewController.startPage =   [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"com.csair.deviceregist/index.html"] absoluteString];
    
    [self.view addSubview:self.aCubeWebViewController.view];
    self.aCubeWebViewController.view.frame = self.view.bounds;
    self.aCubeWebViewController.view.hidden=YES;
    self.aCubeWebViewController.webView.scrollView.bounces=NO;
//    NSLog(@"[DeviceRegister_IphoneControllerViewController] start load WebView date = %@",[NSDate date]);
    
    //预加载
    NSString *url = [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"com.csair.deviceregist/index.html"] absoluteString];
//    NSLog(@"[DeviceRegister_IphoneControllerViewController] page url = %@",url);
    [self.aCubeWebViewController loadWebPageWithUrl: url didFinishBlock: ^(){
        //显示页面
        [self performSelector:@selector(showWebViewController) withObject:nil afterDelay:0.7f];
//        NSLog(@"[DeviceRegister_IphoneControllerViewController]   显示页面");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popMe) name:@"PopDeviceRegistView" object:nil];
//        [self.navigationController pushViewController:self animated:NO];
        
    }didErrorBlock:^(){
        self.aCubeWebViewController.closeButton.hidden = YES;
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备注册模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
    
}
-(void)checkDRFinish{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceRegistFinished" object:nil];
}

-(void)showWebViewController{
    self.aCubeWebViewController.view.hidden=NO;
    self.aCubeWebViewController.closeButton.hidden = YES;
    [self.aCubeWebViewController viewWillAppear:NO];
    [self.aCubeWebViewController viewDidAppear:NO];
//    NSLog(@"finish load WebView date = %@",[NSDate date]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)popMe{
//    NSLog(@"[DeviceRegister_IphoneControllerViewController] popMe");
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
