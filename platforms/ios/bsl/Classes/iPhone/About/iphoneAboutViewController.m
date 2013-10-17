//
//  iphoneAboutViewController.m
//  Cube-iOS
//
//  Created by Mr.幸 on 12-12-26.
//
//

#import "iphoneAboutViewController.h"

@interface iphoneAboutViewController ()

@end

@implementation iphoneAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
         if([[[UIDevice currentDevice] systemVersion] floatValue]>=7){
         self.edgesForExtendedLayout = UIRectEdgeNone;
         self.extendedLayoutIncludesOpaqueBars = NO;
         self.modalPresentationCapturesStatusBarAppearance = YES;
         }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"关于";
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


@end
