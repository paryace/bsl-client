//
//  AboutViewController.m
//  cube-ios
//
//  Created by 东 on 13-3-20.
//
//

#import "AboutViewController.h"
#import "UIDevice+IdentifierAddition.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于我们";
    
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"当前版本 v%@", shortVersion];
    
    NSString *deviceID = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    self.driviceIdLabel.text = deviceID;
    UIImageView *imageView = (UIImageView*)[self.view viewWithTag:100];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGRect frame = imageView.frame;
        frame.size.height =114*2;
        imageView.frame = frame;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setVersionLabel:nil];
    [self setDriviceIdLabel:nil];
    [super viewDidUnload];
}
@end
