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
- (NSString *)documentsPath
{
	NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	return [documentsPaths objectAtIndex:0]; // Path to the application's "~/Documents" directory
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"附件详情";
    self.view.backgroundColor = [UIColor whiteColor];
    if(attachment)
    {
        NSString *fileName = attachment.fileName;
        self.title = fileName;
        fileName  = [fileName lowercaseString];
        if([fileName hasSuffix:@"txt"])
        {
            NSString *path = [[self documentsPath] stringByAppendingPathComponent:@"attachmens"];
            NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
            
            NSArray *realArray = [fileArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF==%@",[attachment.fileId stringByAppendingString:@".txt"]]];
            if(realArray.count >0)
            {
                NSString *file = [realArray objectAtIndex:0];
                NSString *realPath = [path stringByAppendingPathComponent:file];
                BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:realPath isDirectory:NO];
                NSString *content=@"";
                NSError *error;
                if(!isExist)
                {
                    realPath = [attachment downloadFileForPath:attachment.fileId];
                }
                content = [NSString stringWithContentsOfFile:realPath encoding:NSUTF8StringEncoding error:nil];
                if(!content)
                {
                    content = [NSString stringWithContentsOfFile:realPath encoding: 0x80000632 error:&error];
                }
                if(!content)
                {
                    content = [NSString stringWithContentsOfFile:realPath encoding: 0x80000631 error:&error];
                }
                UITextView *textView = [[UITextView alloc]initWithFrame:self.view.frame];
                textView.backgroundColor = [UIColor clearColor];
                textView.font = [UIFont systemFontOfSize:14];
                [self.view addSubview:textView];
//                //下面两行协助 UIWebView 背景透明化，这两属性可以在 xib 中进行设置
//                webview.backgroundColor = [UIColor clearColor];//但是这个属性必须用代码设置，光 xib 设置不行
//                webview.opaque = NO;
//                
//                //这行能在模拟器下明下加快 loadHTMLString 后显示的速度，其实在真机上没有下句也感觉不到加载过程
//                webview.dataDetectorTypes = UIDataDetectorTypeNone;
//                
//                //下面的 backgroud-color:transparent 结合最前面的两行代码指定的属性就真正使得 WebView 的背景透明了
//                //而后的 font:16px/18px 就是设置字体大小为 16px, 行间距为 18px，也可用  line-height: 18px 单独设置行间距
//                //最后的 Custom-Font-Name 就是前面在项目中加上的字体文件所对应的字体名称了
//                NSString *webviewText = @"<style>body{margin:0;background-color:transparent;font:14px/18px Custom-Font-Name}</style>";
//                NSString *htmlString = [webviewText stringByAppendingFormat:@"%@",content];
//                [webview loadHTMLString:htmlString baseURL:nil]; //在 WebView 中显示本地的字符串
            }
        }
        else if([fileName hasSuffix:@"pdf"])
        {
            [self initWebView];
            NSString *path = [[self documentsPath] stringByAppendingPathComponent:@"attachmens"];
            NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
            
            NSArray *realArray = [fileArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF==%@",[attachment.fileId stringByAppendingString:@".pdf"]]];
            if(realArray.count >0)
            {
//                webview.delegate = self;
                webview.multipleTouchEnabled = YES;
                webview.scalesPageToFit = YES;
                webview.backgroundColor = [UIColor whiteColor];
                NSString *file = [realArray objectAtIndex:0];
                NSString *realPath = [path stringByAppendingPathComponent:file];
                NSURL *url = [NSURL fileURLWithPath:realPath];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [webview loadRequest:request];
                
            }
        }
        else
        {
            [self initWebView];
            NSString *path = [[self documentsPath] stringByAppendingPathComponent:@"attachmens"];
            NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
            
            NSArray *realArray = [fileArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF==%@",attachment.fileId]];
            if(realArray.count >0)
            {
                webview.multipleTouchEnabled = YES;
                webview.scalesPageToFit = YES;
                webview.backgroundColor = [UIColor whiteColor];
                NSString *file = [realArray objectAtIndex:0];
                NSString *realPath = [path stringByAppendingPathComponent:file];
                NSURL *url = [NSURL fileURLWithPath:realPath];
                NSString* showHtml = @"<html><head></head><body><img src='data:image/png;base64,%@'/></body></html>";
                NSData* imageData = [[NSData alloc] initWithContentsOfURL:url];
                NSString* imageString = [imageData base64Encoding];
                [webview loadHTMLString:[NSString stringWithFormat:showHtml, imageString] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
            }
        }
    }

}

-(void)initWebView
{
    webview = [[UIWebView alloc]initWithFrame:self.view.frame ];
    CGRect frame = webview.frame;
    frame.size.height =  frame.size.height - self.navigationController.navigationBar.frame.size.height;
    frame.origin.y = 0;
    webview.frame = frame;
    [self.view addSubview:webview];
    
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
