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
                CGRect newframe = self.view.frame;
                newframe.origin.y= 0;
                UITextView *textView = [[UITextView alloc]initWithFrame:newframe];
                textView.text = content;
                
                textView.contentMode = UIViewContentModeScaleAspectFit;
//                NSLog(@"%@---------------%@",textView,self.view);
                
                textView.textColor = [UIColor blackColor];
                textView.backgroundColor = [UIColor clearColor];
                textView.font = [UIFont systemFontOfSize:12];
                textView.editable = NO;
                
//                textView.scrollEnabled = YES;
                textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.view addSubview:textView];
//                [self initWebView];
//                //下面两行协助 UIWebView 背景透明化，这两属性可以在 xib 中进行设置
//                webview.backgroundColor = [UIColor clearColor];//但是这个属性必须用代码设置，光 xib 设置不行
//                webview.opaque = NO;
//                
//                //这行能在模拟器下明下加快 loadHTMLString 后显示的速度，其实在真机上没有下句也感觉不到加载过程
//                webview.dataDetectorTypes = UIDataDetectorTypeNone;
//                
//                //下面的 backgroud-color:transfparent 结合最前面的两行代码指定的属性就真正使得 WebView 的背景透明了
//                //而后的 font:16px/18px 就是设置字体大小为 16px, 行间距为 18px，也可用  line-height: 18px 单独设置行间距
//                //最后的 Custom-Font-Name 就是前面在项目中加上的字体文件所对应的字体名称了
//                content = [NSString stringWithFormat:@"<body><p><pre>%@</pre></p></body>",content];
//                NSString *webviewText = @"<head><style>body{margin:10;background-color:transparent;font:18px/18px }p{ word-wrap:break-word; word-break:normal;}</style></head>";
//                NSString *htmlString = [webviewText stringByAppendingFormat:@"%@",content];
//                
//                [webview loadHTMLString:htmlString baseURL:nil]; //在 WebView 中显示本地的字符串
            }
            else
            {
                
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
                [webview.scrollView setZoomScale:0.1];
                webview.backgroundColor = [UIColor whiteColor];
                NSString *file = [realArray objectAtIndex:0];
                NSString *realPath = [path stringByAppendingPathComponent:file];
                UIImage *image  = [[UIImage alloc]initWithContentsOfFile:realPath];
                
//                float width = 0.0f;
//                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//                {
//                    int height = [[UIApplication sharedApplication]keyWindow].frame.size.height;
//                    if(height/2>image.size.width)
//                    {
//                        width = image.size.width;
//                    }
//                    else
//                    {
//                        width = image.size.width/2 - 20;
//                    }
//                }
//                else
//                {
//                    if(image.size.width > self.view.frame.size.width)
//                    {
//                        width = image.size.width/2 - 20;
//                    }
//                    else
//                    {
//                        width = image.size.width;
//                    }
//                }
                NSString *content;
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    int height = [[UIApplication sharedApplication]keyWindow].frame.size.height;
                    if(height/2>image.size.width)
                    {
                        content= @"";
                    }
                    else{
                        content =@" width=90%";
                    }
                }
                else
                {
                    if(image.size.width > self.view.frame.size.width)
                    {
                        content = @" width=90%";
                    }
                    else
                    {
                        content= @"";
                    }
                }
                NSURL *url = [NSURL fileURLWithPath:realPath];
                NSString* showHtml = @"<html><head><style type=\"text/css\">.aligncenter{clear:both;display:block;margin:auto}</style></head><body><img src='data:image/png;base64,%@' %@ class=\"aligncenter\"/></body></html>";
                NSData* imageData = [[NSData alloc] initWithContentsOfURL:url];
                NSString* imageString = [imageData base64Encoding];
                [webview loadHTMLString:[NSString stringWithFormat:showHtml,imageString,content] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
                
            }
        }
    }
//    else
//    {
//        AttachMents *att = [AttachMents insert];
//        att.fileId = @"T1rRxTBXWT1RCvBVdK";
//        NSString *realPath = [att downloadFileForPath:att.fileId];
//        NSString *content = [NSString stringWithContentsOfFile:realPath encoding:NSUTF8StringEncoding error:nil];
//        NSError *error;
//        if(!content)
//        {
//            content = [NSString stringWithContentsOfFile:realPath encoding: 0x80000632 error:&error];
//        }
//        if(!content)
//        {
//            content = [NSString stringWithContentsOfFile:realPath encoding: 0x80000631 error:&error];
//        }
//        UITextView *textView = [[UITextView alloc]initWithFrame:self.view.frame];
//        textView.backgroundColor = [UIColor clearColor];
//        textView.font = [UIFont systemFontOfSize:14];
//        [self.view addSubview:textView];
//    }

}
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
//    CGRect frame = aWebView.frame;
//    frame.size.height = 1;
//    aWebView.frame = frame;
//    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
//    frame.size = fittingSize;
//    aWebView.frame = frame;
//    
//    NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
//    NSString *str = [NSString stringWithFormat:@"document.documentElement.clientWidth=%f",320.0f];
//    [aWebView stringByEvaluatingJavaScriptFromString:@"alert(document.documentElement.clientWidth);"];
}
-(void)initWebView
{
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        int width = [[UIApplication sharedApplication]keyWindow].frame.size.width;
        int height = [[UIApplication sharedApplication]keyWindow].frame.size.height;
//        NSLog(@"%d------------%d",width,height);
//        NSLog(@"%@",self.view);
        webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, height/2, width - 44) ];
    }
    else
    {
        CGRect frame = self.view.frame;
        frame.origin.y= 0;
        frame.size.height = self.view.frame.size.height -44;
         webview = [[UIWebView alloc]initWithFrame:frame ];
    }
   
//    CGRect frame = webview.frame;
//    NSLog(@"%@",webview);
    webview.delegate = self;
//    webview.scrollView.bounces= NO;
    [webview setScalesPageToFit:YES];
    webview.scrollView.showsHorizontalScrollIndicator=NO;
    webview.scrollView.showsVerticalScrollIndicator=NO;
    webview.scrollView.delegate = self;
//    [[[webview subviews] lastObject] setZoomScale:0.1];
    //webview.scrollView.scrollEnabled = NO;
   
//    frame.size.height =  frame.size.height - self.navigationController.navigationBar.frame.size.height;
//    frame.origin.y = 0;
//    webview.frame = frame;
//    [webview sizeThatFits:CGSizeMake(frame.size.width, frame.size.height)];
    [self.view addSubview:webview];
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //NSLog(@"scrollViewDidZoom %f",scrollview.zoomScale);
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
