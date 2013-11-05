//
//  AttachmentImageView.m
//  bsl
//
//  Created by zhoujun on 13-11-4.
//
//

#import "AttachmentImageView.h"
#import "AttachMents.h"
@implementation AttachmentImageView
@synthesize fileName;
@synthesize fileId;
@synthesize fileSize;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
-(void)openFile:(NSString*)attachmentId
{
    AttachMents *attachment = [AttachMents getByPredicate:[NSPredicate predicateWithFormat:@"fileId=%@",attachmentId]];
    NSString *realPath = [NSHomeDirectory() stringByAppendingPathComponent:[attachment filePath]];
    CGRect frame = [[UIApplication sharedApplication]keyWindow].frame;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:realPath]];
    webView = [[CubeWebViewController alloc]init];
    [webView loadRequest:request withFrame:frame didFinishBlock:^{} didErrorBlock:^{}];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
