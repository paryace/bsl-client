//
//  ImageAttachViewController.m
//  bsl
//
//  Created by zhoujun on 13-11-6.
//
//

#import "ImageAttachViewController.h"

@interface ImageAttachViewController ()

@end

@implementation ImageAttachViewController
@synthesize filepath;

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
    self.view.backgroundColor = [UIColor whiteColor];
    imageView = [[MRZoomScrollView alloc]initWithFrame:self.view.frame ];
    [self.view addSubview:imageView];
    if(filepath)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:filepath];
        [imageView.imageView setImage:image];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
