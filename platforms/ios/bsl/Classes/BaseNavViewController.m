//
//  BaseNavViewController.m
//  bsl
//
//  Created by 肖昶 on 13-10-9.
//
//

#import "BaseNavViewController.h"

@interface BaseNavViewController ()<UINavigationControllerDelegate>
-(void)didClickBack;
-(UIButton*) backButtonWith:(UIImage*)buttonImage highlight:(UIImage*)backButtonHighlightImage;
@end

@implementation BaseNavViewController{
    
}

-(id)init{
    self=[super init];
    if(self){
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = YES;
        }
        
    }

    return self;
}

-(id)initWithRootViewController:(UIViewController *)rootViewController{
    self=[super initWithRootViewController:rootViewController];
    if(self){
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = YES;
        }

    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //if (UI_USER_INTERFACE_IDIOM() !=  UIUserInterfaceIdiomPad){
        self.delegate=self;
    
        UIImage *image = [UIImage imageNamed:(UI_USER_INTERFACE_IDIOM() !=  UIUserInterfaceIdiomPad) ? @"nav_bg.png":@"nav_bg_pad.png"];
        [image stretchableImageWithLeftCapWidth:20 topCapHeight:0];
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    
    
    //}
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIButton*) backButtonWith:(UIImage*)buttonImage highlight:(UIImage*)backButtonHighlightImage {
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickBack) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)didClickBack{
    [self popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if([navigationController.viewControllers count]>1){
        UIButton* backButton = [self backButtonWith:[UIImage imageNamed:@"nav_back.png"] highlight:[UIImage imageNamed:@"nav_back_active.png"]];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    else{
        viewController.navigationItem.leftBarButtonItem=nil;
    }
}



@end
