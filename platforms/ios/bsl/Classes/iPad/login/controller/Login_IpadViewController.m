//
//  Login_IpadViewController.m
//  cube-ios
//
//  Created by 东 on 5/30/13.
//
//

#import "Login_IpadViewController.h"
#import "CubeWebViewController.h"
#import "NSFileManager+Extra.h"

@interface Login_IpadViewController (){
    BOOL isDisappear;
}

@end

@implementation Login_IpadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }

    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIImage* img=[UIImage imageNamed:@"Default-Landscape~ipad.png"];
    UIImageView* bgImageView =  [[UIImageView alloc]initWithImage:img];

    [self.view addSubview:bgImageView];

    [aCubeWebViewController.view removeFromSuperview];
    aCubeWebViewController=nil;

    aCubeWebViewController  = [[CubeWebViewController alloc] init];
    //aCubeWebViewController.title=module.name;
    //加载本地的登录界面页
    //设置启动页面
    aCubeWebViewController.title=@"登录";
    aCubeWebViewController.wwwFolderName = @"www";
    aCubeWebViewController.startPage =   [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"pad/login.html"] absoluteString];
    aCubeWebViewController.view.frame = self.view.bounds;
    aCubeWebViewController.webView.scrollView.bounces=NO;
    [self.view addSubview:aCubeWebViewController.view];
    aCubeWebViewController.view.hidden=YES;
    [aCubeWebViewController loadWebPageWithUrl: [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"pad/login.html"] absoluteString] didFinishBlock: ^(){
        [self performSelector:@selector(showWebViewController) withObject:nil afterDelay:1.0f];
    }didErrorBlock:^(){
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登陆模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

-(void)showWebViewController{
    aCubeWebViewController.view.hidden=NO;
    [aCubeWebViewController viewWillAppear:NO];
    [aCubeWebViewController viewDidAppear:NO];

}

- (void)didReceiveMemoryWarning{
    [aCubeWebViewController.view removeFromSuperview];
    aCubeWebViewController=nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (isDisappear) {
        
        NSURL *url =[NSURL URLWithString: [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"pad/login.html"]absoluteString]];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        [aCubeWebViewController.webView loadRequest:request];
        isDisappear = false;
     
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    
    isDisappear = YES;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


@end
