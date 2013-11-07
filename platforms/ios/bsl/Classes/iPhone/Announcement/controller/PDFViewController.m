//
//  PDFViewController.m
//  bsl
//
//  Created by zhoujun on 13-11-6.
//
//

#import "PDFViewController.h"

@interface PDFViewController ()

@end

@implementation PDFViewController
@synthesize attachment;
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
    webView = [[UIWebView alloc]initWithFrame:self.view.frame ];
    [self.view addSubview:webView];
    if(attachment)
    {
        NSString *fileName = attachment.fileName;
        [self loadDocument:fileName inView:webView];
    }
	// Do any additional setup after loading the view.
}
-(void)loadDocument:(NSString *)documentName inView:(UIWebView *)myWebView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:documentName ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [myWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
